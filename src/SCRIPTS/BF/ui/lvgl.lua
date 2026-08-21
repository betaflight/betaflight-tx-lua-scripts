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
--   * Rebuilding destroys focus and scroll position -- and recreating the
--     page recreates its header, which cannot be done invisibly: the firmware
--     creates the nav buttons a frame after the page, and until the first
--     focus move the header's invisible menu button wears the focus ring as a
--     white pill over the EdgeTX logo. So the page shell is built once per
--     visit, and page turns swap only the rows under it.
--   * A page file lies until the flight controller has answered: postLoad
--     rewrites ranges from the reply (profiles.lua turns PID Profile's
--     declared 0..1 into 0..count-1), so a row built early is built as the
--     wrong control and flashes into the right one when the values land.
--     Field rows are therefore only built from arrived values; while a page
--     loads, the previous page's rows stay up, greyed.

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

-- Which screen the current LVGL tree was built for. `none` means the next frame
-- rebuilds: it is how an action says the tree it was invoked from is stale.
local VIEW = {
    none = 0,
    init = 1,
    mainMenu = 2,
    page = 3,
    confirm = 4,
}

local view = VIEW.none
local builtPage -- the Page the rows were built from
local builtValues -- and whether its values had arrived
local builtReady -- and whether it was ready to carry field rows at all
local pageShell -- the lvgl.page the rows live in, while the page view is up
local swapPending -- rows cleared this frame; the refill lands next frame
local bodyStale -- an edit rewrote the field tables under the built rows
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
            -- Picking an entry is a whole edit, so postEdit fires here; the
            -- rates-type field's rewrites every rate row's range and label,
            -- which only a row swap can show. upd hooks need no swap: they
            -- rewrite values and label texts, which the widgets watch through
            -- their bound getters.
            Controller.setFieldValue(f, index - 1 + base)
            Controller.postEdit(f)
            if f.postEdit then
                bodyStale = true
            end
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
            Controller.postEdit(f)
            if f.postEdit then
                bodyStale = true
            end
        end,
        active = function()
            return fieldEditable(f)
        end,
    })
end

--- How many decimal places a scale implies: 100 puts the point two digits in.
--- Scales below 1 (ACTUAL rates store degrees-per-second divided by ten) spread
--- the raw byte out to a larger whole number, so they get none.
local function decimalsOf(scale)
    local d = 0
    while scale > 1 do
        scale = scale / 10
        d = d + 1
    end
    return d
end

local function addNumber(box, f, w)
    -- numberEdit holds an integer, so it works in the field's raw units --
    -- f.min and f.max are already raw -- and a display handler renders the
    -- scaled value the user knows: RC Rate byte 120 reads "1.20". This also
    -- makes one detent one raw step, the field's actual resolution; handing
    -- the widget the scaled value instead would floor 1.20 to "1".
    local scale = f.scale or 1
    local fmt = "%." .. decimalsOf(scale) .. "f"
    box:numberEdit({
        w = w,
        min = f.min or 0,
        max = f.max or 255,
        get = function()
            return math.floor((f.value or 0) * scale + 0.5)
        end,
        set = function(v)
            Controller.setFieldValue(f, v / scale)
        end,
        display = scale ~= 1 and function(v)
            return string.format(fmt, v / scale)
        end or nil,
        edited = function(v)
            Controller.setFieldValue(f, v / scale)
            Controller.postEdit(f)
            -- postEdit can rewrite min, max and scale across the whole page
            -- (rates.lua does, on all nine rate fields at once). A built
            -- numberEdit's range cannot follow that, so the rows are swapped
            -- out instead, once the edit the user is in has finished. upd
            -- hooks rewrite only values and label texts, which the bound
            -- getters carry without a rebuild.
            if f.postEdit then
                bodyStale = true
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
    local geom = geometryOf(#row.fields, rowTitle(row) ~= "")
    local setting = container:setting({
        w = FULL,
        -- Bound rather than copied: the firmware re-reads a function title
        -- every frame, which is how pos_osd's element selector renames its
        -- own row from an upd hook without anything being rebuilt.
        title = function()
            return rowTitle(row)
        end,
    })
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

--- Whether the page can be trusted to build widgets from. Ranges and value
--- tables are not final until the reply has been through postLoad, and a read
--- the FC refused clears Page.read on its way to becoming the N/A notice, so
--- "no values and nothing on order" also counts as arrived.
local function pageReady(Page)
    return Page.read == nil or Page.values ~= nil
end

local function subtitle()
    if Controller.saving then
        return Controller.retrying() and "Retrying..." or "Saving..."
    end
    if not Controller.hasTelemetry() then
        return "No Telemetry"
    end
    local Page = Controller.Page
    if Page and not pageReady(Page) then
        return "Loading..."
    end
    if Page and Page.title then
        return Page.title
    end
    return ""
end

--- Page navigation holds still while a save is in flight: leaving the page
--- mid-transaction abandons it after the MSP_SET_* and before the eepromWrite.
--- The block is this check inside each press, never `active` on the header
--- arrows -- disabling those buttons mid-save wedges the firmware's encoder
--- group, after which no rotary or key input ever lands again. A page turn
--- that quietly does nothing for the half second a save takes costs less.
local function canChangePage()
    return not Controller.saving
end

--- Build a view. The rows go straight onto the page rather than into a box of
--- our own: lvgl.page already gives you a body that scrolls and takes a flex
--- layout, and a box inside it is a second scroll container nested in the
--- first, with its own scroll bar and its own idea of where the top is.
---
--- A page of settings sits tighter than a list of buttons, which want a gap
--- wide enough to read as separate targets, so the row spacing is per view.
local function newPage(opts, flexPad)
    opts.flexFlow = lvgl.FLOW_COLUMN
    opts.flexPad = flexPad
    opts.borderPad = BODY_PAD
    return lvgl.page(opts)
end

--- A gap between two groups of rows. An hline would read better, but a line is
--- a simple widget rather than a window and never decodes PERCENT_SIZE, so a
--- full-width one takes the sentinel literally and flattens the whole column.
local function addSpacer(body)
    body:box({ w = FULL, h = lvgl.PAD_LARGE })
end

--- The one action that belongs to the open page, at the end of the form, which
--- is where a colour radio puts the button that submits one. It goes inactive
--- while a save is in flight so a second press cannot start a second
--- transaction on a link that is already busy.
local function addSaveRow(body)
    body:button({
        w = FULL,
        text = "Save page",
        press = function()
            if Controller.Page then
                Controller.savePage()
            end
        end,
        active = function()
            return not Controller.saving
        end,
    })
end

-- Every view sets backButton and none sets menu, which the firmware reads as:
-- draw the exit cross top right and wire it to `back`, and leave the top-left
-- header tile calling nothing. Without backButton there is no cross at all and
-- the only way out by touch is that tile, which looks like the EdgeTX logo and
-- reads like one. An inert logo costs a touch user nothing; an invisible exit
-- costs them the way out. pcallSimpleFunc returns early on LUA_REFNIL, so the
-- unset menu callback is a no-op rather than an error.

--- Everything below the header: the rows, or word that they are coming.
local function fillBody(body)
    local Page = Controller.Page
    if not Page or not pageReady(Page) then
        body:label({ w = FULL, text = "Loading..." })
        return
    end
    local rows = rowsOf(Page)
    for i = 1, #rows do
        addRow(body, rows[i])
    end
    addSpacer(body)
    addSaveRow(body)
end

local function buildPage()
    lvgl.clear()
    pageShell = newPage({
        title = "Betaflight",
        subtitle = subtitle,
        backButton = true,
        back = function()
            Controller.exitPage()
            view = VIEW.none
        end,
        -- Page turns leave `view` alone: the shell stays, and the change of
        -- Controller.Page swaps the rows under it.
        prevButton = {
            press = function()
                if canChangePage() then
                    Controller.prevPage()
                end
            end,
        },
        nextButton = {
            press = function()
                if canChangePage() then
                    Controller.nextPage()
                end
            end,
        },
    }, lvgl.PAD_SMALL)
    fillBody(pageShell)
end

local function buildMainMenu()
    lvgl.clear()
    local body = newPage({
        title = "Betaflight",
        subtitle = "Configuration",
        backButton = true,
        back = function()
            UI.shouldExit = true
        end,
    }, lvgl.PAD_MEDIUM)
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

    -- The flight-controller actions live here rather than behind a menu on a
    -- settings page, which is where the lcd renderer keeps them: none of them
    -- has anything to do with the page that happens to be open.
    addSpacer(body)
    body:label({ w = FULL, text = "Flight Controller", font = BOLD })
    local actions = Controller.fcActions()
    for i = 1, #actions do
        local action = actions[i]
        body:button({
            w = FULL,
            text = action.title or action.t,
            press = function()
                action.f()
                view = VIEW.none
            end,
        })
    end
end

local function buildInit()
    lvgl.clear()
    local body = newPage({
        title = "Betaflight",
        subtitle = "Connecting",
        backButton = true,
        back = function()
            UI.shouldExit = true
        end,
    }, lvgl.PAD_MEDIUM)
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
    local body = newPage({
        title = "Betaflight",
        subtitle = Page.title or "Confirm",
        backButton = true,
        back = function()
            Controller.confirmCancel()
            view = VIEW.none
        end,
    }, lvgl.PAD_MEDIUM)
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

-- ============================================================================
-- Frame
-- ============================================================================

--- Which view the current tool state calls for.
local function wantedView()
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
    -- Readiness can flip without values ever arriving: a refused read becomes
    -- the N/A notice, which `values == builtValues` alone would never notice.
    local ready = Page ~= nil and pageReady(Page)

    -- Content changes while the page view is up swap the rows and leave the
    -- shell standing; only a change of view rebuilds the whole screen. Two
    -- rules make the swap invisible:
    --
    --   * Swap only once the incoming page is ready. Until then the outgoing
    --     rows stay up -- greyed, their fields no longer being editable --
    --     which reads as a page turn in progress rather than a blink through
    --     an empty screen.
    --   * The firmware releases a cleared object's child refs after this
    --     frame's run() returns, and rows built before that sweep would be
    --     swept with them. So: clear this frame, refill the next.
    if want == VIEW.page and view == VIEW.page and pageShell then
        if swapPending then
            swapPending = false
            bodyStale = false
            builtPage, builtValues, builtReady = Page, values, ready
            fillBody(pageShell)
        elseif ready and (Page ~= builtPage or values ~= builtValues or ready ~= builtReady or bodyStale) then
            pageShell:clear()
            swapPending = true
        end
        return
    end

    if want == view and Page == builtPage and values == builtValues and ready == builtReady then
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
    builtReady = ready
    pageShell = nil
    swapPending = false
    bodyStale = false

    if want == VIEW.init then
        buildInit()
    elseif want == VIEW.mainMenu then
        buildMainMenu()
    elseif want == VIEW.confirm then
        buildConfirm()
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
            killEvents(event) -- X10/T16 issue: pageUp is a long press
        elseif event == EVT_VIRTUAL_NEXT_PAGE then
            Controller.nextPage()
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
