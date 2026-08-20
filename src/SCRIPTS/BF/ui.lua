-- The lcd.* renderer: 128x64 and 212x64 monochrome, and every colour radio
-- whose firmware predates the LVGL page API.
--
-- Everything that is not drawing moved to controller.lua. What is left owns the
-- pixels and the keys -- focus, scrolling, edit mode, the popup menu box, the
-- event ladder -- and reaches the rest through Controller intents.

local Controller = assert(loadScript("controller.lua"))()
local template = assert(loadScript(radio.template))()

local status = Controller.status

-- Editing is a property of this renderer, not of the tool: it means "the rotary
-- is retargeted at a value". Saving lives on the Controller, because a colour
-- UI shows it without having a mode for it.
local pageStatus =
{
    display = 1,
    editing = 2,
}

local pageState = pageStatus.display
local currentField = 1
local pageScrollY = 0
local mainMenuScrollY = 0
local popupMenu, popupMenuActive
local killEnterBreak = 0
local lastState = status.init

local backgroundFill = COLOR_THEME_SECONDARY3 or TEXT_BGCOLOR or ERASE
local foregroundColor = COLOR_THEME_PRIMARY3 or LINE_COLOR or SOLID

local globalTextOptions = COLOR_THEME_SECONDARY1 or TEXT_COLOR or 0

local function incField(inc)
    currentField = clipValue(currentField + inc, 1, #Controller.Page.fields)
end

local function incPopupMenu(inc)
    popupMenuActive = clipValue(popupMenuActive + inc, 1, #popupMenu)
end

local function createPopupMenu()
    popupMenuActive = 1
    popupMenu = Controller.menuActions()
end

local function drawScreenTitle(screenTitle)
    if radio.highRes then
        lcd.drawFilledRectangle(0, 0, LCD_W, template.lineSpacing + template.margin, COLOR_THEME_SECONDARY1 or TITLE_BGCOLOR)
        lcd.drawText(template.margin,template.margin,screenTitle, COLOR_THEME_PRIMARY2 or MENU_TITLE_COLOR)
    else
        lcd.drawFilledRectangle(0, 0, LCD_W, 10, FORCE)
        lcd.drawText(1,1,screenTitle,INVERS)
    end
end

local function drawScreen()
    local Page = Controller.Page
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

local function drawSaveBox()
    local saveMsg = "Saving..."
    if Controller.retrying() then
        saveMsg = "Retrying"
    end
    lcd.drawFilledRectangle(radio.SaveBox.x,radio.SaveBox.y,radio.SaveBox.w,radio.SaveBox.h,backgroundFill)
    lcd.drawRectangle(radio.SaveBox.x,radio.SaveBox.y,radio.SaveBox.w,radio.SaveBox.h,SOLID)
    lcd.drawText(radio.SaveBox.x+radio.SaveBox.x_offset,radio.SaveBox.y+radio.SaveBox.h_offset,saveMsg,DBLSIZE + globalTextOptions)
end

local function drawMainMenu()
    lcd.clear()
    local yMinLim = radio.yMinLimit
    local yMaxLim = radio.yMaxLimit
    local lineSpacing = template.lineSpacing
    local currentFieldY = (Controller.currentPage-1)*lineSpacing + yMinLim
    if currentFieldY <= yMinLim then
        mainMenuScrollY = 0
    elseif currentFieldY - mainMenuScrollY <= yMinLim then
        mainMenuScrollY = currentFieldY - yMinLim
    elseif currentFieldY - mainMenuScrollY >= yMaxLim then
        mainMenuScrollY = currentFieldY - yMaxLim
    end
    for i=1, #Controller.PageFiles do
        local attr = Controller.currentPage == i and INVERS or 0
        local y = (i-1)*lineSpacing + yMinLim - mainMenuScrollY
        if y >= 0 and y <= LCD_H then
            lcd.drawText(6, y, Controller.PageFiles[i].title, attr)
        end
    end
    drawScreenTitle("Betaflight Config")
end

local function run_ui(event)
    -- Edit mode cannot outlive the page it was editing. The single-function
    -- version got this for free by keeping editing and saving in one variable
    -- that page invalidation reset; now that they are apart, say it.
    if not Controller.Page then
        pageState = pageStatus.display
    end

    -- Entering a confirmation replaces the page under us, from wherever the
    -- popup menu was opened, so focus resets here rather than at each caller.
    if Controller.state == status.confirm and lastState ~= status.confirm then
        currentField = 1
    end
    lastState = Controller.state

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
    elseif Controller.state == status.init then
        lcd.clear()
        drawScreenTitle("Betaflight Config")
        lcd.drawText(6, radio.yMinLimit, Controller.initText())
        if not Controller.initStep() then
            return 0
        end
    elseif Controller.state == status.mainMenu then
        if event == EVT_VIRTUAL_EXIT then
            return 2
        elseif event == EVT_VIRTUAL_NEXT then
            Controller.selectMenuEntry(1)
        elseif event == EVT_VIRTUAL_PREV then
            Controller.selectMenuEntry(-1)
        elseif event == EVT_VIRTUAL_ENTER then
            Controller.openPage()
        elseif event == EVT_VIRTUAL_ENTER_LONG then
            killEnterBreak = 1
            createPopupMenu()
        end
        drawMainMenu()
    elseif Controller.state == status.pages then
        if Controller.saving then
            Controller.tickSaving()
        elseif pageState == pageStatus.display then
            if event == EVT_VIRTUAL_PREV_PAGE then
                currentField = 1
                Controller.prevPage()
                killEvents(event) -- X10/T16 issue: pageUp is a long press
            elseif event == EVT_VIRTUAL_NEXT_PAGE then
                currentField = 1
                Controller.nextPage()
            elseif event == EVT_VIRTUAL_PREV or event == EVT_VIRTUAL_PREV_REPT then
                incField(-1)
            elseif event == EVT_VIRTUAL_NEXT or event == EVT_VIRTUAL_NEXT_REPT then
                incField(1)
            elseif event == EVT_VIRTUAL_ENTER then
                if Controller.Page and Controller.isFieldEditable(Controller.Page.fields[currentField]) then
                    pageState = pageStatus.editing
                end
            elseif event == EVT_VIRTUAL_ENTER_LONG then
                killEnterBreak = 1
                createPopupMenu()
            elseif event == EVT_VIRTUAL_EXIT then
                currentField = 1
                Controller.exitPage()
                return 0
            end
        elseif pageState == pageStatus.editing then
            if event == EVT_VIRTUAL_EXIT or event == EVT_VIRTUAL_ENTER then
                Controller.postEdit(Controller.Page.fields[currentField])
                pageState = pageStatus.display
            elseif event == EVT_VIRTUAL_INC or event == EVT_VIRTUAL_INC_REPT then
                Controller.incFieldValue(Controller.Page.fields[currentField], 1)
            elseif event == EVT_VIRTUAL_DEC or event == EVT_VIRTUAL_DEC_REPT then
                Controller.incFieldValue(Controller.Page.fields[currentField], -1)
            end
        end
        Controller.selectPage()
        if pageState == pageStatus.display then
            Controller.requestPageIfNeeded()
        end
        lcd.clear()
        drawScreen()
        if Controller.saving then
            drawSaveBox()
        end
    elseif Controller.state == status.confirm then
        lcd.clear()
        drawScreen()
        if event == EVT_VIRTUAL_ENTER then
            Controller.confirmAccept()
        elseif event == EVT_VIRTUAL_EXIT then
            Controller.confirmCancel()
        end
    end
    if not Controller.hasTelemetry() then
        lcd.drawText(radio.NoTelem[1],radio.NoTelem[2],radio.NoTelem[3],radio.NoTelem[4])
    end
    Controller.tick()
    return 0
end

return run_ui
