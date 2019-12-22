local uiStatus =
{
    init     = 1,
    pages    = 2,
    mainMenu = 3,
}

local pageStatus =
{
    display     = 2,
    editing     = 3,
    saving      = 4,
    popupMenu   = 5,
}

local uiMsp =
{
    reboot = 68,
    eepromWrite = 250
}

local uiState = uiStatus.init
local pageState = pageStatus.display
local requestTimeout = 80 -- 800ms request timeout
local currentPage = 1
local currentField = 1
local saveTS = 0
local saveTimeout = 0
local saveRetries = 0
local saveMaxRetries = 0
local popupMenuActive = false
local lastRunTS = 0
local killEnterBreak = 0
local stopDisplay = false
local pageScrollY = 0
local mainMenuScrollY = 0
local PageFiles = nil
local Page = nil
local background = nil

local backgroundFill = TEXT_BGCOLOR or ERASE
local foregroundColor = LINE_COLOR or SOLID

local globalTextOptions = TEXT_COLOR or 0

local function saveSettings(new)
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
            saveMaxRetries = protocol.saveMaxRetries or 2 -- default 2
            saveTimeout = protocol.saveTimeout or 150     -- default 1.5s
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

local popupMenuList = {
    {
        t = "save page",
        f = saveSettings
    },
    {
        t = "reload",
        f = invalidatePages
    },
    {
        t = "reboot",
        f = rebootFc
    }
}

local function processMspReply(cmd,rx_buf)
    if cmd == nil or rx_buf == nil then
        return
    end
    if Page == nil then
        return
    end
    if cmd == Page.write then
        if Page.eepromWrite then
            eepromWrite()
        else
            invalidatePages()
        end
        return
    end
    if cmd == uiMsp.eepromWrite then
        if Page.reboot then
            rebootFc()
        end
        invalidatePages()
        return
    end
    if cmd ~= Page.read then
        return
    end
    if #(rx_buf) > 0 then
        Page.values = rx_buf
        for i=1,#(Page.fields) do
            if (#(Page.values) or 0) >= Page.minBytes then
                local f = Page.fields[i]
                if f.vals then
                    f.value = 0;
                    for idx=1, #(f.vals) do
                        local raw_val = (Page.values[f.vals[idx]] or 0)
                        raw_val = bit32.lshift(raw_val, (idx-1)*8)
                        f.value = bit32.bor(f.value, raw_val)
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
    currentPage = incMax(currentPage, inc, #(PageFiles))
    Page = nil
    currentField = 1
    collectgarbage()
end

local function incField(inc)
    currentField = clipValue(currentField + inc, 1, #(Page.fields))
end

local function incMainMenu(inc)
    currentPage = clipValue(currentPage + inc, 1, #PageFiles)
end

local function incPopupMenu(inc)
    popupMenuActive = clipValue(popupMenuActive + inc, 1, #(popupMenuList))
end

local function requestPage()
    if Page.read and ((Page.reqTS == nil) or (Page.reqTS + requestTimeout <= getTime())) then
        Page.reqTS = getTime()
        protocol.mspRead(Page.read)
    end
end

local function drawScreenTitle(screen_title)
    if radio.resolution == lcdResolution.low then
        lcd.drawFilledRectangle(0, 0, LCD_W, 10)
        lcd.drawText(1,1,screen_title,INVERS)
    else
        lcd.drawFilledRectangle(0, 0, LCD_W, 30, TITLE_BGCOLOR)
        lcd.drawText(5,5,screen_title, MENU_TITLE_COLOR)
    end
end

local function drawScreen()
    local yMinLim = radio.yMinLimit or 0
    local yMaxLim = radio.yMaxLimit or LCD_H
    local currentFieldY = Page.fields[currentField].y
    local screenTitle = Page.title
    local textOptions = radio.textSize + globalTextOptions
    drawScreenTitle("Betaflight / "..screenTitle)
    if currentFieldY <= Page.fields[1].y then
        pageScrollY = 0
    elseif currentFieldY - pageScrollY <= yMinLim then
        pageScrollY = currentFieldY - yMinLim
    elseif currentFieldY - pageScrollY >= yMaxLim then
        pageScrollY = currentFieldY - yMaxLim
    end
    for i=1,#(Page.labels) do
        local f = Page.labels[i]
        if (f.y - pageScrollY) >= yMinLim and (f.y - pageScrollY) <= yMaxLim then
            lcd.drawText(f.x, f.y - pageScrollY, f.t, textOptions)
        end
    end
    local val = "---"
    for i=1,#(Page.fields) do
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
        if (f.y - pageScrollY) >= yMinLim and (f.y - pageScrollY) <= yMaxLim then
            if f.t then
                lcd.drawText(f.x, f.y - pageScrollY, f.t, textOptions)
            end
            lcd.drawText(f.sp or f.x, f.y - pageScrollY, val, valueOptions)
        end
    end
end

local function incValue(inc)
    local f = Page.fields[currentField]
    local scale = (f.scale or 1)
    local mult = (f.mult or 1)
    f.value = clipValue(f.value + ((inc*mult)/scale), ((f.min or 0)/scale), ((f.max or 255)/scale))
    f.value = math.floor((f.value*scale)/mult + 0.5)/(scale/mult)
    for idx=1, #(f.vals) do
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
    local h = #(popupMenuList) * h_line + h_offset*2

    lcd.drawFilledRectangle(x,y,w,h,backgroundFill)
    lcd.drawRectangle(x,y,w-1,h-1,foregroundColor)
    lcd.drawText(x+h_line/2,y+h_offset,"Menu:",globalTextOptions)

    for i,e in ipairs(popupMenuList) do
        local text_options = globalTextOptions
        if popupMenuActive == i then
            text_options = text_options + INVERS
        end
        lcd.drawText(x+radio.MenuBox.x_offset,y+(i-1)*h_line+h_offset,e.t,text_options)
    end
end

local function run_ui(event)
    local now = getTime()
    -- if lastRunTS old than 500ms
    if lastRunTS + 50 < now then
        invalidatePages()
        uiState = uiStatus.init
    end
    lastRunTS = now
    if uiState == uiStatus.init then
        local yMinLim = radio.yMinLimit
        lcd.clear()
        drawScreenTitle("Betaflight Config", 0, 0)
        lcd.drawText(6, yMinLim, "Initialising")
        if apiVersion == 0 then
            if not background then
                background = assert(loadScript("/SCRIPTS/BF/background.lua"))()
            end
            background()
            return 0
        else
            background = nil
            PageFiles = assert(loadScript("/SCRIPTS/BF/pages.lua"))()
            invalidatePages()
            if isTelemetryScript then
                uiState = uiStatus.pages
            else
                uiState = uiStatus.mainMenu
            end
        end
    elseif uiState == uiStatus.mainMenu then
        if event == EVT_VIRTUAL_EXIT then
            return 2
        elseif event == EVT_VIRTUAL_NEXT then
            incMainMenu(1)
        elseif event == EVT_VIRTUAL_PREV then
            incMainMenu(-1)
        elseif event == EVT_VIRTUAL_ENTER then
            pageState = pageStatus.display
            uiState = uiStatus.pages
        end
        lcd.clear()
        drawScreenTitle("Betaflight Config", 0, 0)
        local yMinLim = radio.yMinLimit
        local yMaxLim = radio.yMaxLimit
        local lineSpacing = 10
        if radio.resolution == lcdResolution.high then
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
            local attr = (currentPage == i and INVERS or 0)
            if ((i-1)*lineSpacing + yMinLim - mainMenuScrollY) >= yMinLim and ((i-1)*lineSpacing + yMinLim - mainMenuScrollY) <= yMaxLim then
                lcd.drawText(6, (i-1)*lineSpacing + yMinLim - mainMenuScrollY, PageFiles[i].title, attr)
            end
        end
    elseif uiState == uiStatus.pages then
        if (pageState == pageStatus.saving) then
            if (saveTS + saveTimeout < now) then
                if saveRetries < saveMaxRetries then
                    saveSettings()
                else
                    -- max retries reached
                    pageState = pageStatus.display
                    invalidatePages()
                end
            end
        end
        -- navigation
        if isTelemetryScript and event == EVT_VIRTUAL_MENU_LONG then -- telemetry script
            popupMenuActive = 1
            pageState = pageStatus.popupMenu
        elseif (not isTelemetryScript) and event == EVT_VIRTUAL_ENTER_LONG then -- standalone
            popupMenuActive = 1
            killEnterBreak = 1
            pageState = pageStatus.popupMenu
        -- menu is currently displayed
        elseif pageState == pageStatus.popupMenu then
            if event == EVT_VIRTUAL_EXIT then
                pageState = pageStatus.display
            elseif event == EVT_VIRTUAL_PREV then
                incPopupMenu(-1)
            elseif event == EVT_VIRTUAL_NEXT then
                incPopupMenu(1)
            elseif event == EVT_VIRTUAL_ENTER then
                if killEnterBreak == 1 then
                    killEnterBreak = 0
                else
                    pageState = pageStatus.display
                    popupMenuList[popupMenuActive].f()
                end
            end
        -- normal page viewing
        elseif pageState <= pageStatus.display then
            if not isTelemetryScript and event == EVT_VIRTUAL_PREV_PAGE then
                incPage(-1)
                killEvents(event) -- X10/T16 issue: pageUp is a long press
            elseif (not isTelemetryScript and event == EVT_VIRTUAL_NEXT_PAGE) or (isTelemetryScript and event == EVT_VIRTUAL_MENU) then
                incPage(1)
            elseif event == EVT_VIRTUAL_PREV or event == EVT_VIRTUAL_PREV_REPT then
                incField(-1)
            elseif event == EVT_VIRTUAL_NEXT or event == EVT_VIRTUAL_NEXT_REPT then
                incField(1)
            elseif event == EVT_VIRTUAL_ENTER then
                if Page then
                    local f = Page.fields[currentField]
                    if Page.values and Page.values[f.vals[#f.vals]] and not f.ro then
                        pageState = pageStatus.editing
                    end
                end
            elseif event == EVT_VIRTUAL_EXIT then
                if isTelemetryScript then 
                    return protocol.exitFunc();
                else
                    stopDisplay = true
                end
            end
        -- editing value
        elseif pageState == pageStatus.editing then
            if event == EVT_VIRTUAL_EXIT or event == EVT_VIRTUAL_ENTER then
                pageState = pageStatus.display
            elseif event == EVT_VIRTUAL_INC or event == EVT_VIRTUAL_INC_REPT then
                incValue(1)
            elseif event == EVT_VIRTUAL_DEC or event == EVT_VIRTUAL_DEC_REPT then
                incValue(-1)
            end
        end
        if Page == nil then
            if #PageFiles == 0 then
                lcd.clear()
                lcd.drawText(radio.NoTelem[1], radio.NoTelem[2], "No Pages! API: " .. apiVersion, radio.NoTelem[4])
                return 1
            end
            Page = assert(loadScript(SCRIPT_HOME.."/Pages/"..PageFiles[currentPage].script))()
            collectgarbage()
        end
        if not Page.values and pageState == pageStatus.display then
            requestPage()
        end
        lcd.clear()
        if TEXT_BGCOLOR then
            lcd.drawFilledRectangle(0, 0, LCD_W, LCD_H, TEXT_BGCOLOR)
        end
        drawScreen()
        if pageState == pageStatus.popupMenu then
            drawPopupMenu()
        elseif pageState == pageStatus.saving then
            lcd.drawFilledRectangle(radio.SaveBox.x,radio.SaveBox.y,radio.SaveBox.w,radio.SaveBox.h,backgroundFill)
            lcd.drawRectangle(radio.SaveBox.x,radio.SaveBox.y,radio.SaveBox.w,radio.SaveBox.h,SOLID)
            if saveRetries <= 0 then
                lcd.drawText(radio.SaveBox.x+radio.SaveBox.x_offset,radio.SaveBox.y+radio.SaveBox.h_offset,"Saving...",DBLSIZE + BLINK + (globalTextOptions))
            else
                lcd.drawText(radio.SaveBox.x+radio.SaveBox.x_offset,radio.SaveBox.y+radio.SaveBox.h_offset,"Retrying",DBLSIZE + (globalTextOptions))
            end
        end
        if stopDisplay and (not isTelemetryScript) then
            invalidatePages()
            currentField = 1
            uiState = uiStatus.mainMenu
            stopDisplay = false
        end
    end
    -- process send queue
    mspProcessTxQ()
    if protocol.rssi() == 0 then
        lcd.drawText(radio.NoTelem[1],radio.NoTelem[2],radio.NoTelem[3],radio.NoTelem[4])
    end
    processMspReply(mspPollReply())
    return 0
end

return run_ui
