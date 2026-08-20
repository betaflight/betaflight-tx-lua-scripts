-- The LVGL renderer: colour radios on EdgeTX 2.11.4 or later.
--
-- Same controller, same page files, native widgets. Rows are built from the
-- coordinates the page files already carry -- fields sharing a y are one visual
-- row, and a label at that y is its title -- so the grid pages (PIDs, GPS PIDs)
-- come out as one setting per axis with three number editors side by side,
-- which is how people tune, without any page needing to know this file exists.
--
-- Three rules this file exists under, each of which has a way of biting:
--
--   * An error inside a bound getter kills the tool, and with it the MSP pump
--     at the bottom of the frame -- possibly after an MSP_SET_* but before its
--     eepromWrite. Every getter here answers with a default rather than
--     indexing something that might be nil.
--   * Rebuilding destroys focus and scroll position, so it happens only when
--     the view genuinely changes: a different page, values arriving for the
--     first time, or an edit that rewrote the field table underneath us.
--   * numberEdit does not poll its get() on this firmware, so a row built
--     before the flight controller answered would show 0 for ever. The
--     values-arrived rebuild is what covers that, and it lands before anyone
--     can have touched a control.

local loader = assert(loadScript("loader.lua"))()

local Controller = loader("controller.lua")
local status = Controller.status

local UI = {}

local FULL = lvgl.PERCENT_SIZE + 100

-- 320-wide radios have less room for a title beside the controls it names.
local IS_NARROW = LCD_W < 400

-- How much of a row its title takes. A row with one editor keeps EdgeTX's own
-- half-and-half proportions; a grid row's title is a single word ("ROLL") and
-- the columns need the rest of the line -- at half, the third editor starts
-- past the right edge, because an editor left to size itself takes a fixed
-- 100px (EdgeTxStyles::EDIT_FLD_WIDTH) no matter how many share the row.
local LIST_TITLE_PCT = IS_NARROW and 42 or 50
local GRID_TITLE_PCT = IS_NARROW and 34 or 26

-- The theme draws the scroll bar inside the box and a focus outline around the
-- control rather than beside it, so a full-width child of an unpadded box ends
-- up flush against both. This is the room for them.
local BODY_PAD = {
    left = lvgl.PAD_MEDIUM,
    right = lvgl.PAD_LARGE,
    top = lvgl.PAD_SMALL,
    bottom = lvgl.PAD_MEDIUM,
}

-- Which screen the current LVGL tree was built for. Kept apart from
-- Controller.state because the popup menu is a view here, not a tool state.
local VIEW = {
    none = 0,
    init = 1,
    mainMenu = 2,
    page = 3,
    confirm = 4,
    menu = 5,
}

local view = VIEW.none
local builtPage -- the Page the tree was built from
local builtValues -- and whether its values had arrived
local menuReturnView
local lastEvent -- see UI.render: the firmware delivers each key twice

-- ============================================================================
-- Field classification
-- ============================================================================

--- A range with nothing in it. postLoad derives some of these from a count the
--- flight controller sent (profiles.lua sets max to pidProfileCount - 1), so a
--- reply that has not arrived, or arrived empty, leaves min above max. Anything
--- built from that would be an empty control the user could focus and not use.
local function isEmptyRange(f)
    return (f.max or 255) < (f.min or 0)
end

--- A value table covers the field when it has an entry for every step in
--- range. Sparse ones (rx.lua's { [0] = "Auto" } over 0..255) are numbers with
--- one named value, not a choice.
local function isDenseTable(f)
    if not f.table or (f.scale or 1) ~= 1 or isEmptyRange(f) then
        return false
    end
    for i = f.min or 0, f.max or 255 do
        if f.table[i] == nil then
            return false
        end
    end
    return true
end

local function isToggle(f)
    return isDenseTable(f) and (f.min or 0) == 0 and f.max == 1
end

--- What the value reads as, for the rows that only display it.
local function displayValue(f)
    local v = f.value
    if v == nil then
        return "---"
    end
    if f.table and f.table[v] ~= nil then
        return tostring(f.table[v])
    end
    return tostring(v)
end

local function fieldEditable(f)
    return Controller.isFieldEditable(f)
end

-- ============================================================================
-- Widgets
-- ============================================================================

local function addChoice(box, f, w)
    -- BF value tables start at f.min, usually 0; lvgl.choice is 1-based.
    local base = f.min or 0
    local values = {}
    for i = base, f.max or 255 do
        values[#values + 1] = tostring(f.table[i])
    end
    box:choice({
        w = w,
        title = f.t or "",
        values = values,
        get = function()
            return (f.value or base) - base + 1
        end,
        set = function(index)
            Controller.setFieldValue(f, index - 1 + base)
        end,
        active = function()
            return fieldEditable(f)
        end,
    })
end

local function addToggle(box, f)
    box:toggle({
        get = function()
            return f.value or 0
        end,
        set = function(v)
            Controller.setFieldValue(f, v)
        end,
        active = function()
            return fieldEditable(f)
        end,
    })
end

local function addNumber(box, f, w)
    local scale = f.scale or 1
    box:numberEdit({
        w = w,
        -- min/max are raw bytes; the value the user sees is scaled.
        min = (f.min or 0) / scale,
        max = (f.max or 255) / scale,
        get = function()
            return f.value or 0
        end,
        set = function(v)
            Controller.setFieldValue(f, v)
        end,
        edited = function(v)
            Controller.setFieldValue(f, v)
            Controller.postEdit(f)
            -- postEdit can rewrite min, max and scale across the whole page
            -- (rates.lua does, on all nine rate fields at once). numberEdit has
            -- no way to take that, so the tree is rebuilt instead. Confined to
            -- fields that asked for a postEdit, which the user has just
            -- finished editing.
            if f.postEdit then
                view = VIEW.none
            end
        end,
        active = function()
            return fieldEditable(f)
        end,
    })
end

local function addLabel(box, f, w)
    box:label({
        w = w,
        text = function()
            return displayValue(f)
        end,
    })
end

--- `w` is nil for a row with one editor, which leaves each control its natural
--- width, and a percentage of the row for a grid, where three of those natural
--- widths do not fit.
local function addWidget(box, f, w)
    if f.ro or not f.vals or isEmptyRange(f) then
        addLabel(box, f, w)
    elseif isToggle(f) then
        -- A toggle is a fixed-size switch; stretching it to a column would draw
        -- a switch with a gap after it rather than a wider switch.
        addToggle(box, f)
    elseif isDenseTable(f) then
        addChoice(box, f, w)
    else
        addNumber(box, f, w)
    end
end

-- ============================================================================
-- Rows
-- ============================================================================

local function byX(a, b)
    return (a.x or 0) < (b.x or 0)
end

--- The text that titles a row. A field's own `t` wins; otherwise the leftmost
--- label sharing its line, which is how the grid pages name their axes.
local function rowTitle(row)
    if #row.fields == 1 and row.fields[1].t then
        return row.fields[1].t
    end
    for i = 1, #row.labels do
        local l = row.labels[i]
        if l.t and l.t ~= "" then
            return l.t
        end
    end
    return ""
end

--- Where a row's title ends and its columns begin. Everything on one line
--- shares this, so a column header lands over the editor it names.
local function geometryOf(cols, hasTitle)
    if cols < 2 then
        return { cols = 1, titlePct = hasTitle and LIST_TITLE_PCT or 0 }
    end
    local titlePct = hasTitle and GRID_TITLE_PCT or 0
    return {
        cols = cols,
        titlePct = titlePct,
        boxPct = 100 - titlePct,
        -- The two points held back per column pay for the flex gap between the
        -- editors and the focus outline around the last one.
        colPct = math.floor(100 / cols) - 2,
    }
end

--- A run of label-only lines above a grid, folded into one row carrying a text
--- per column. Each page file puts a header label at the same x as the column
--- it heads, which is the mapping used here; rates.lua splits "RC Rate" over
--- two such lines, so texts landing in the same column are joined.
local function headerRow(rows, from, to, target)
    local texts = {}
    for i = from, to do
        local labels = rows[i].labels
        for k = 1, #labels do
            local l = labels[k]
            local col = 0 -- 0 is the title column, left of the first editor
            for c = 1, #target.fields do
                if target.fields[c].x == l.x then
                    col = c
                    break
                end
            end
            if l.t and l.t ~= "" then
                texts[col] = texts[col] and (texts[col] .. " " .. l.t) or l.t
            end
        end
    end
    return {
        y = rows[from].y,
        labels = {},
        fields = {},
        texts = texts,
        geom = geometryOf(#target.fields, rowTitle(target) ~= ""),
    }
end

local function headsAGrid(row)
    return #row.fields == 0 and #row.labels > 1
end

--- Group a page's labels and fields by y. Pages lay themselves out in screen
--- order, so a shared y is a shared line: one field is a setting, three are a
--- grid row, and none at all is a heading or a column header.
local function rowsOf(Page)
    local byY, ys = {}, {}
    local function slot(y)
        if not byY[y] then
            byY[y] = { y = y, labels = {}, fields = {} }
            ys[#ys + 1] = y
        end
        return byY[y]
    end
    for i = 1, #Page.labels do
        local l = Page.labels[i]
        local row = slot(l.y)
        row.labels[#row.labels + 1] = l
    end
    for i = 1, #Page.fields do
        local f = Page.fields[i]
        local row = slot(f.y)
        row.fields[#row.fields + 1] = f
    end
    table.sort(ys)

    local rows = {}
    for i = 1, #ys do
        local row = byY[ys[i]]
        -- Columns are read left to right; the page files fill them top to
        -- bottom, so insertion order is not it.
        table.sort(row.labels, byX)
        table.sort(row.fields, byX)
        rows[#rows + 1] = row
    end

    local out = {}
    local i = 1
    while i <= #rows do
        local j = i
        while j <= #rows and headsAGrid(rows[j]) do
            j = j + 1
        end
        if j > i and rows[j] and #rows[j].fields > 1 then
            out[#out + 1] = headerRow(rows, i, j - 1, rows[j])
            i = j
        else
            out[#out + 1] = rows[i]
            i = i + 1
        end
    end
    return out
end

--- The box holding a row's controls, starting where its title ends.
local function valueBox(setting, geom)
    return setting:box({
        x = geom.titlePct > 0 and (lvgl.PERCENT_SIZE + geom.titlePct) or nil,
        w = geom.boxPct and (lvgl.PERCENT_SIZE + geom.boxPct) or nil,
        flexFlow = lvgl.FLOW_ROW,
        flexPad = lvgl.PAD_SMALL,
        align = LEFT,
    })
end

local function addHeadingRow(container, row)
    local parts = {}
    for i = 1, #row.labels do
        if row.labels[i].t and row.labels[i].t ~= "" then
            parts[#parts + 1] = row.labels[i].t
        end
    end
    if #parts == 0 then
        return
    end
    container:label({ w = FULL, text = table.concat(parts, "  "), font = BOLD })
end

local function addHeaderRow(container, row)
    local geom = row.geom
    local setting = container:setting({ w = FULL, title = row.texts[0] or "" })
    local box = valueBox(setting, geom)
    for c = 1, geom.cols do
        box:label({
            w = lvgl.PERCENT_SIZE + geom.colPct,
            text = row.texts[c] or "",
            font = BOLD,
            align = CENTER,
        })
    end
end

local function addFieldRow(container, row)
    local title = rowTitle(row)
    local geom = geometryOf(#row.fields, title ~= "")
    local setting = container:setting({ w = FULL, title = title })
    local box = valueBox(setting, geom)
    local w = geom.colPct and (lvgl.PERCENT_SIZE + geom.colPct) or nil
    for i = 1, #row.fields do
        addWidget(box, row.fields[i], w)
    end
end

local function addRow(container, row)
    if row.texts then
        addHeaderRow(container, row)
    elseif #row.fields == 0 then
        addHeadingRow(container, row)
    else
        addFieldRow(container, row)
    end
end

-- ============================================================================
-- Views
-- ============================================================================

local function subtitle()
    if Controller.saving then
        return Controller.retrying() and "Retrying..." or "Saving..."
    end
    if not Controller.hasTelemetry() then
        return "No Telemetry"
    end
    local Page = Controller.Page
    if Page and Page.title then
        return Page.title
    end
    return ""
end

--- Page navigation is greyed out rather than hidden while a save is in flight:
--- leaving the page mid-transaction abandons it after the MSP_SET_* and before
--- the eepromWrite.
local function canChangePage()
    return not Controller.saving
end

local function openMenuFrom(from)
    menuReturnView = from
    view = VIEW.none
    UI.pendingView = VIEW.menu
end

--- The scrolling column every view fills. A page of settings sits tighter than
--- a list of buttons, which want a gap wide enough to read as separate targets.
local function bodyBox(pg, flexPad)
    return pg:box({
        w = FULL,
        flexFlow = lvgl.FLOW_COLUMN,
        flexPad = flexPad,
        borderPad = BODY_PAD,
    })
end

local function buildPage()
    lvgl.clear()
    local Page = Controller.Page
    local openMenu = function()
        openMenuFrom(VIEW.page)
    end
    local pg = lvgl.page({
        title = "Betaflight",
        subtitle = subtitle,
        backButton = true,
        back = function()
            Controller.exitPage()
            view = VIEW.none
        end,
        menu = openMenu,
        prevButton = {
            press = function()
                Controller.prevPage()
                view = VIEW.none
            end,
            active = canChangePage,
        },
        nextButton = {
            press = function()
                Controller.nextPage()
                view = VIEW.none
            end,
            active = canChangePage,
        },
    })

    local body = bodyBox(pg, lvgl.PAD_SMALL)

    -- The header's menu button is touch-only -- the firmware maps no key to it
    -- -- and the menu is where "save page" lives, so it needs a row as well.
    -- First rather than last: it is what the rotary lands on when a page opens,
    -- and a save should not be at the bottom of a scroll.
    body:button({
        w = FULL,
        text = "Menu",
        press = openMenu,
    })

    local rows = rowsOf(Page)
    for i = 1, #rows do
        addRow(body, rows[i])
    end
end

local function buildMainMenu()
    lvgl.clear()
    local pg = lvgl.page({
        title = "Betaflight",
        subtitle = "Configuration",
        back = function()
            UI.shouldExit = true
        end,
        menu = function()
            openMenuFrom(VIEW.mainMenu)
        end,
    })
    local body = bodyBox(pg, lvgl.PAD_MEDIUM)
    body:button({
        w = FULL,
        text = "Menu",
        press = function()
            openMenuFrom(VIEW.mainMenu)
        end,
    })
    for i = 1, #Controller.PageFiles do
        local index = i
        body:button({
            w = FULL,
            text = Controller.PageFiles[i].title,
            press = function()
                Controller.currentPage = index
                Controller.reload()
                Controller.openPage()
                view = VIEW.none
            end,
        })
    end
end

local function buildInit()
    lvgl.clear()
    local pg = lvgl.page({
        title = "Betaflight",
        subtitle = "Connecting",
        back = function()
            UI.shouldExit = true
        end,
    })
    local body = bodyBox(pg, lvgl.PAD_MEDIUM)
    body:label({
        w = FULL,
        text = function()
            return Controller.initText()
        end,
    })
end

local function buildConfirm()
    lvgl.clear()
    local Page = Controller.Page
    local pg = lvgl.page({
        title = "Betaflight",
        subtitle = Page.title or "Confirm",
        backButton = true,
        back = function()
            Controller.confirmCancel()
            view = VIEW.none
        end,
    })
    local body = bodyBox(pg, lvgl.PAD_MEDIUM)
    for i = 1, #Page.labels do
        body:label({ w = FULL, text = Page.labels[i].t or "" })
    end
    body:button({
        w = FULL,
        text = "Confirm",
        press = function()
            Controller.confirmAccept()
            view = VIEW.none
        end,
    })
end

--- The popup menu, as a page of its own. The lcd renderer draws a box over the
--- screen; here the header's menu button opens this and the back button
--- returns, which is what a colour radio user expects.
local function buildMenu()
    lvgl.clear()
    local actions = Controller.menuActions()
    local pg = lvgl.page({
        title = "Betaflight",
        subtitle = "Menu",
        backButton = true,
        back = function()
            view = VIEW.none
            UI.pendingView = menuReturnView
        end,
    })
    local body = bodyBox(pg, lvgl.PAD_MEDIUM)
    for i = 1, #actions do
        local action = actions[i]
        body:button({
            w = FULL,
            text = action.t,
            press = function()
                action.f()
                view = VIEW.none
                -- An action that opened a confirmation has already moved the
                -- tool on; anything else goes back where the menu came from.
                UI.pendingView = nil
            end,
        })
    end
end

-- ============================================================================
-- Frame
-- ============================================================================

--- Which view the current tool state calls for, unless something explicitly
--- asked for another one.
local function wantedView()
    if UI.pendingView then
        local v = UI.pendingView
        UI.pendingView = nil
        return v
    end
    if view == VIEW.menu then
        return VIEW.menu
    end
    if Controller.state == status.init then
        return VIEW.init
    elseif Controller.state == status.mainMenu then
        return VIEW.mainMenu
    elseif Controller.state == status.confirm then
        return VIEW.confirm
    end
    return VIEW.page
end

local function rebuildIfNeeded()
    local want = wantedView()
    local Page = Controller.Page
    local values = Page and Page.values or nil

    if want == view and Page == builtPage and values == builtValues then
        return
    end

    -- The page view has nothing to draw until its page is loaded, and the
    -- confirm view likewise. Wait rather than build an empty tree.
    if (want == VIEW.page or want == VIEW.confirm) and not Page then
        return
    end
    if want == VIEW.mainMenu and not Controller.PageFiles then
        return
    end

    view = want
    builtPage = Page
    builtValues = values

    if want == VIEW.init then
        buildInit()
    elseif want == VIEW.mainMenu then
        buildMainMenu()
    elseif want == VIEW.confirm then
        buildConfirm()
    elseif want == VIEW.menu then
        buildMenu()
    else
        buildPage()
    end
end

function UI.render(event)
    -- Every key event arrives twice. WidgetPage::onEvent queues it for the
    -- script and then bubbles it to StandaloneLuaWindow::onEvent, which queues
    -- it again, and the Lua event buffer hands them out one per frame -- so one
    -- press of PAGE would step two pages. killEvents is no help; it clears the
    -- key state, not the buffer. The copies always land on consecutive frames,
    -- which no pair of real presses can.
    local duplicate = event ~= 0 and event == lastEvent
    lastEvent = event

    -- The PAGE keys are not wired to prevButton/nextButton by the firmware --
    -- those are touch only -- so the physical keys are handled here.
    if not duplicate and Controller.state == status.pages and canChangePage() then
        if event == EVT_VIRTUAL_PREV_PAGE then
            Controller.prevPage()
            view = VIEW.none
            killEvents(event) -- X10/T16 issue: pageUp is a long press
        elseif event == EVT_VIRTUAL_NEXT_PAGE then
            Controller.nextPage()
            view = VIEW.none
        end
    end

    if Controller.state == status.init then
        if not Controller.initStep() then
            rebuildIfNeeded()
            return 0
        end
    elseif Controller.state == status.pages then
        if Controller.saving then
            Controller.tickSaving()
        end
        Controller.selectPage()
        if not Controller.saving then
            Controller.requestPageIfNeeded()
        end
    end

    rebuildIfNeeded()
    Controller.tick()

    if UI.shouldExit then
        return 2
    end
    return 0
end

return UI
