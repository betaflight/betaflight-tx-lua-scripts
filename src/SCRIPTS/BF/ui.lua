local uiStatus =
{
    init     = 1,
    mainMenu = 2,
    pages    = 3,
    confirm  = 4,
}

local pageStatus =
{
    display = 1,
    editing = 2,
    saving  = 3,
}

local uiMsp =
{
    reboot = 68,
    eepromWrite = 250,
}

local uiState = uiStatus.init
local prevUiState
local pageState = pageStatus.display
local requestTimeout = 80
local currentPage = 1
local currentField = 1
local saveTS = 0
local saveTimeout = protocol.saveTimeout
local saveRetries = 0
local saveMaxRetries = protocol.saveMaxRetries
local popupMenuActive = 1
local killEnterBreak = 0
local pageScrollY = 0
local mainMenuScrollY = 0
local PageFiles, Page, init, popupMenu

local backgroundFill = TEXT_BGCOLOR or ERASE
local foregroundColor = LINE_COLOR or SOLID

local globalTextOptions = TEXT_COLOR or 0

local function saveSettings()
    if Page.values then
        local payload = Page.values
        if Page.preSave then
            payload = Page.preSave(Page)
        end
        protocol.mspWrite(Page.write, payload)
        saveTS = getTime()
        if pageState == pageStatus.saving then
            saveRetries = saveRetries + 1
        else
            pageState = pageStatus.saving
            saveRetries = 0
        end
    end
end

local function invalidatePages()
    Page = nil
    pageState = pageStatus.display
    saveTS = 0
    collectgarbage()
end

local function rebootFc()
    protocol.mspRead(uiMsp.reboot)
    invalidatePages()
end

local function eepromWrite()
    protocol.mspRead(uiMsp.eepromWrite)
end

local function confirm(page)
    prevUiState = uiState
    uiState = uiStatus.confirm
    invalidatePages()
    currentField = 1
    Page = assert(loadScript(page))()
    collectgarbage()
end

local function createPopupMenu()
    popupMenuActive = 1
    popupMenu = {}
    if uiState == uiStatus.pages then
        popupMenu[#popupMenu + 1] = { t = "save page", f = saveSettings }
        popupMenu[#popupMenu + 1] = { t = "reload", f = invalidatePages }
    end
    popupMenu[#popupMenu + 1] = { t = "reboot", f = rebootFc }
    popupMenu[#popupMenu + 1] = { t = "acc cal", f = function() confirm("CONFIRM/acc_cal.lua") end }
    if apiVersion >= 1.42 then
        popupMenu[#popupMenu + 1] = { t = "vtx tables", f = function() confirm("CONFIRM/vtx_tables.lua") end }
    end
end

local function processMspReply(cmd,rx_buf)
    if not Page or not rx_buf then
    elseif cmd == Page.write then
        if Page.eepromWrite then
            eepromWrite()
        else
            invalidatePages()
        end
    elseif cmd == uiMsp.eepromWrite then
        if Page.reboot then
            rebootFc()
        end
        invalidatePages()
    elseif cmd == Page.read and #rx_buf > 0 then
        Page.values = rx_buf
        for i=1,#Page.fields do
            if #Page.values >= Page.minBytes then
                local f = Page.fields[i]
                if f.vals then
                    f.value = 0
                    for idx=1, #f.vals do
                        local raw_val = Page.values[f.vals[idx]] or 0
                        raw_val = bit32.lshift(raw_val, (idx-1)*8)
                        f.value = bit32.bor(f.value, raw_val)
                    end
                    local bits = #f.vals * 8
                    if f.min and f.min < 0 and bit32.btest(f.value, bit32.lshift(1, bits - 1)) then
                        f.value = f.value - (2 ^ bits)
                    end
                    f.value = f.value/(f.scale or 1)
                end
            end
        end
        if Page.postLoad then
            Page.postLoad(Page)
        end
    end
end

local function incMax(val, inc, base)
    return ((val + inc + base - 1) % base) + 1
end

function clipValue(val,min,max)
    if val < min then
        val = min
    elseif val > max then
        val = max
    end
    return val
end

local function incPage(inc)
    currentPage = incMax(currentPage, inc, #PageFiles)
    currentField = 1
    invalidatePages()
end

local function incField(inc)
    currentField = clipValue(currentField + inc, 1, #Page.fields)
end

local function incMainMenu(inc)
    currentPage = clipValue(currentPage + inc, 1, #PageFiles)
end

local function incPopupMenu(inc)
    popupMenuActive = clipValue(popupMenuActive + inc, 1, #popupMenu)
end

local function requestPage()
    if Page.read and ((not Page.reqTS) or (Page.reqTS + requestTimeout <= getTime())) then
        Page.reqTS = getTime()
        protocol.mspRead(Page.read)
    end
end

local function drawScreenTitle(screenTitle)
    if radio.highRes then
        lcd.drawFilledRectangle(0, 0, LCD_W, 30, TITLE_BGCOLOR)
        lcd.drawText(5,5,screenTitle, MENU_TITLE_COLOR)
    else
        lcd.drawFilledRectangle(0, 0, LCD_W, 10, FORCE)
        lcd.drawText(1,1,screenTitle,INVERS)
    end
end

local function drawScreen()
    local yMinLim = radio.yMinLimit
    local yMaxLim = radio.yMaxLimit
    local currentFieldY = Page.fields[currentField].y
    local textOptions = radio.textSize + globalTextOptions
    if currentFieldY <= Page.fields[1].y then
        pageScrollY = 0
    elseif currentFieldY - pageScrollY <= yMinLim then
        pageScrollY = currentFieldY - yMinLim
    elseif currentFieldY - pageScrollY >= yMaxLim then
        pageScrollY = currentFieldY - yMaxLim
    end
    for i=1,#Page.labels do
        local f = Page.labels[i]
        local y = f.y - pageScrollY
        if y >= 0 and y <= LCD_H then
            lcd.drawText(f.x, y, f.t, textOptions)
        end
    end
    local val = "---"
    for i=1,#Page.fields do
        local f = Page.fields[i]
        local valueOptions = textOptions
        if i == currentField then
            valueOptions = valueOptions + INVERS
            if pageState == pageStatus.editing then
                valueOptions = valueOptions + BLINK
            end
        end 
        if f.value then
            if f.upd and Page.values then
                f.upd(Page)
            end
            val = f.value
            if f.table and f.table[f.value] then
                val = f.table[f.value]
            end
        end
        local y = f.y - pageScrollY
        if y >= 0 and y <= LCD_H then
            if f.t then
                lcd.drawText(f.x, y, f.t, textOptions)
            end
            lcd.drawText(f.sp or f.x, y, val, valueOptions)
        end
    end
    drawScreenTitle("Betaflight / "..Page.title)
end

local function incValue(inc)
    local f = Page.fields[currentField]
    local scale = f.scale or 1
    local mult = f.mult or 1
    f.value = clipValue(f.value + inc*mult/scale, (f.min or 0)/scale, (f.max or 255)/scale)
    f.value = math.floor(f.value*scale/mult + 0.5)*mult/scale
    for idx=1, #f.vals do
        Page.values[f.vals[idx]] = bit32.rshift(math.floor(f.value*scale + 0.5), (idx-1)*8)
    end
    if f.upd and Page.values then
        f.upd(Page)
    end
end

local function drawPopupMenu()
    local x = radio.MenuBox.x
    local y = radio.MenuBox.y
    local w = radio.MenuBox.w
    local h_line = radio.MenuBox.h_line
    local h_offset = radio.MenuBox.h_offset
    local h = #popupMenu * h_line + h_offset*2

    lcd.drawFilledRectangle(x,y,w,h,backgroundFill)
    lcd.drawRectangle(x,y,w-1,h-1,foregroundColor)
    lcd.drawText(x+h_line/2,y+h_offset,"Menu:",globalTextOptions)

    for i,e in ipairs(popupMenu) do
        local textOptions = globalTextOptions
        if popupMenuActive == i then
            textOptions = textOptions + INVERS
        end
        lcd.drawText(x+radio.MenuBox.x_offset,y+(i-1)*h_line+h_offset,e.t,textOptions)
    end
end

local function run_ui(event)
    if popupMenu then
        drawPopupMenu()
        if event == EVT_VIRTUAL_EXIT then
            popupMenu = nil
        elseif event == EVT_VIRTUAL_PREV then
            incPopupMenu(-1)
        elseif event == EVT_VIRTUAL_NEXT then
            incPopupMenu(1)
        elseif event == EVT_VIRTUAL_ENTER then
            if killEnterBreak == 1 then
                killEnterBreak = 0
            else
                popupMenu[popupMenuActive].f()
                popupMenu = nil
            end
        end
    elseif uiState == uiStatus.init then
        lcd.clear()
        drawScreenTitle("Betaflight Config")
        init = init or assert(loadScript("ui_init.lua"))()
        lcd.drawText(6, radio.yMinLimit, init.t)
        if not init.f() then
            return 0
        end
        init = nil
        PageFiles = assert(loadScript("pages.lua"))()
        invalidatePages()
        uiState = prevUiState or uiStatus.mainMenu
        prevUiState = nil
    elseif uiState == uiStatus.mainMenu then
        if event == EVT_VIRTUAL_EXIT then
            return 2
        elseif event == EVT_VIRTUAL_NEXT then
            incMainMenu(1)
        elseif event == EVT_VIRTUAL_PREV then
            incMainMenu(-1)
        elseif event == EVT_VIRTUAL_ENTER then
            uiState = uiStatus.pages
        elseif event == EVT_VIRTUAL_ENTER_LONG then
            killEnterBreak = 1
            createPopupMenu()
        end
        lcd.clear()
        local yMinLim = radio.yMinLimit
        local yMaxLim = radio.yMaxLimit
        local lineSpacing = 10
        if radio.highRes then
            lineSpacing = 25
        end
        local currentFieldY = (currentPage-1)*lineSpacing + yMinLim
        if currentFieldY <= yMinLim then
            mainMenuScrollY = 0
        elseif currentFieldY - mainMenuScrollY <= yMinLim then
            mainMenuScrollY = currentFieldY - yMinLim
        elseif currentFieldY - mainMenuScrollY >= yMaxLim then
            mainMenuScrollY = currentFieldY - yMaxLim
        end
        for i=1, #PageFiles do
            local attr = currentPage == i and INVERS or 0
            local y = (i-1)*lineSpacing + yMinLim - mainMenuScrollY
            if y >= 0 and y <= LCD_H then
                lcd.drawText(6, y, PageFiles[i].title, attr)
            end
        end
        drawScreenTitle("Betaflight Config")
    elseif uiState == uiStatus.pages then
        if pageState == pageStatus.saving then
            if saveTS + saveTimeout < getTime() then
                if saveRetries < saveMaxRetries then
                    saveSettings()
                else
                    pageState = pageStatus.display
                    invalidatePages()
                end
            end
        elseif pageState == pageStatus.display then
            if event == EVT_VIRTUAL_PREV_PAGE then
                incPage(-1)
                killEvents(event) -- X10/T16 issue: pageUp is a long press
            elseif event == EVT_VIRTUAL_NEXT_PAGE then
                incPage(1)
            elseif event == EVT_VIRTUAL_PREV or event == EVT_VIRTUAL_PREV_REPT then
                incField(-1)
            elseif event == EVT_VIRTUAL_NEXT or event == EVT_VIRTUAL_NEXT_REPT then
                incField(1)
            elseif event == EVT_VIRTUAL_ENTER then
                if Page then
                    local f = Page.fields[currentField]
                    if Page.values and f.vals and Page.values[f.vals[#f.vals]] and not f.ro then
                        pageState = pageStatus.editing
                    end
                end
            elseif event == EVT_VIRTUAL_ENTER_LONG then
                killEnterBreak = 1
                createPopupMenu()
            elseif event == EVT_VIRTUAL_EXIT then
                invalidatePages()
                currentField = 1
                uiState = uiStatus.mainMenu
                return 0
            end
        elseif pageState == pageStatus.editing then
            if event == EVT_VIRTUAL_EXIT or event == EVT_VIRTUAL_ENTER then
                if Page.fields[currentField].postEdit then
                    Page.fields[currentField].postEdit(Page)
                end
                pageState = pageStatus.display
            elseif event == EVT_VIRTUAL_INC or event == EVT_VIRTUAL_INC_REPT then
                incValue(1)
            elseif event == EVT_VIRTUAL_DEC or event == EVT_VIRTUAL_DEC_REPT then
                incValue(-1)
            end
        end
        if not Page then
            Page = assert(loadScript("PAGES/"..PageFiles[currentPage].script))()
            collectgarbage()
        end
        if not Page.values and pageState == pageStatus.display then
            requestPage()
        end
        lcd.clear()
        drawScreen()
        if pageState == pageStatus.saving then
            local saveMsg = "Saving..."
            if saveRetries > 0 then
                saveMsg = "Retrying"
            end
            lcd.drawFilledRectangle(radio.SaveBox.x,radio.SaveBox.y,radio.SaveBox.w,radio.SaveBox.h,backgroundFill)
            lcd.drawRectangle(radio.SaveBox.x,radio.SaveBox.y,radio.SaveBox.w,radio.SaveBox.h,SOLID)
            lcd.drawText(radio.SaveBox.x+radio.SaveBox.x_offset,radio.SaveBox.y+radio.SaveBox.h_offset,saveMsg,DBLSIZE + globalTextOptions)
        end
    elseif uiState == uiStatus.confirm then
        lcd.clear()
        drawScreen()
        if event == EVT_VIRTUAL_ENTER then
            uiState = uiStatus.init
            init = Page.init
            invalidatePages()
        elseif event == EVT_VIRTUAL_EXIT then
            invalidatePages()
            uiState = prevUiState
            prevUiState = nil
        end
    end
    if getRSSI() == 0 then
        lcd.drawText(radio.NoTelem[1],radio.NoTelem[2],radio.NoTelem[3],radio.NoTelem[4])
    end
    mspProcessTxQ()
    processMspReply(mspPollReply())
    return 0
end

return run_ui
