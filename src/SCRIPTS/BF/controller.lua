-- Everything the tool does that is not drawing.
--
-- The split runs along one line: whatever a colour radio would do the same way
-- as a 128x64 one lives here, and whatever depends on how the screen is built
-- lives in the renderer. So this file owns the state machine, page load and
-- unload, the MSP request/reply pump, byte packing, and which entries the
-- popup menu offers -- and knows nothing about lcd.*, lvgl, coordinates,
-- scrolling, focus, or events.
--
-- Callers reach it through intent (openPage, savePage, incFieldValue), never
-- by poking state, so a second renderer needs no second copy of any of this.

local loader = assert(loadScript("loader.lua"))()

local Controller = {}

-- Where the tool is. The renderer switches on this and nothing else.
Controller.status = {
    init = 1,
    mainMenu = 2,
    pages = 3,
    confirm = 4,
}
local status = Controller.status

local uiMsp = {
    reboot = 68,
    eepromWrite = 250,
}

local requestTimeout = 80
local saveTimeout = protocol.saveTimeout
local saveMaxRetries = protocol.saveMaxRetries

local prevState
local saveTS = 0
local saveRetries = 0
local init

--- Read by the renderer, written only here.
Controller.state = status.init
Controller.Page = nil
Controller.PageFiles = nil
Controller.currentPage = 1
Controller.saving = false

-- ============================================================================
-- Globals the pages rely on
-- ============================================================================

-- vtx.lua calls this, and pages are loaded into the same global environment,
-- so it has to stay a global rather than become a Controller method.
function clipValue(val, min, max)
    if val < min then
        val = min
    elseif val > max then
        val = max
    end
    return val
end

-- ============================================================================
-- Page lifecycle
-- ============================================================================

--- Drop the loaded page so the next frame re-reads it from the FC.
function Controller.reload()
    Controller.Page = nil
    Controller.saving = false
    saveTS = 0
    collectgarbage()
end

local function incMax(val, inc, base)
    return ((val + inc + base - 1) % base) + 1
end

--- Load the page for currentPage, diverting to a confirmation screen when the
--- page declares a precondition that is not met (a missing board info or VTX
--- table the FC has to be asked for first).
function Controller.selectPage()
    if Controller.Page then
        return
    end
    local selected = Controller.PageFiles[Controller.currentPage]
    if selected.init then
        local divert = loader(selected.init)
        if divert then
            Controller.confirm(divert)
            return
        end
    end
    Controller.Page = loader("PAGES/" .. selected.script)
    collectgarbage()
end

function Controller.nextPage()
    Controller.currentPage = incMax(Controller.currentPage, 1, #Controller.PageFiles)
    Controller.reload()
end

function Controller.prevPage()
    Controller.currentPage = incMax(Controller.currentPage, -1, #Controller.PageFiles)
    Controller.reload()
end

--- Move the main-menu selection, clamped rather than wrapped -- the menu is a
--- list, the page ring is a ring, and they have always behaved differently.
function Controller.selectMenuEntry(inc)
    Controller.currentPage = clipValue(Controller.currentPage + inc, 1, #Controller.PageFiles)
end

function Controller.openPage()
    Controller.state = status.pages
end

function Controller.exitPage()
    Controller.reload()
    Controller.state = status.mainMenu
end

-- ============================================================================
-- Confirmation screens
-- ============================================================================

function Controller.confirm(script)
    prevState = Controller.state
    Controller.state = status.confirm
    Controller.reload()
    Controller.Page = loader(script)
    collectgarbage()
end

--- Accepting a confirmation hands its init step back to the init state, which
--- runs it frame by frame until it reports done.
function Controller.confirmAccept()
    Controller.state = status.init
    init = Controller.Page.init
    Controller.reload()
end

function Controller.confirmCancel()
    Controller.reload()
    Controller.state = prevState
    prevState = nil
end

-- ============================================================================
-- Init
-- ============================================================================

--- What the init screen should say. Read before initStep so the renderer shows
--- the phase that has just finished, which is the order the single-function
--- version drew in.
function Controller.initText()
    init = init or loader("ui_init.lua")
    return init.t
end

--- One frame of the connect handshake. True once the tool is ready to run.
function Controller.initStep()
    init = init or loader("ui_init.lua")
    if not init.f() then
        return false
    end
    init = nil
    Controller.PageFiles = loader("pages.lua")
    Controller.reload()
    Controller.state = prevState or status.mainMenu
    prevState = nil
    return true
end

-- ============================================================================
-- Save, reboot, menu
-- ============================================================================

function Controller.savePage()
    local Page = Controller.Page
    if not Page.values then
        return
    end
    local payload = Page.values
    if Page.preSave then
        payload = Page.preSave(Page)
    end
    protocol.mspWrite(Page.write, payload)
    saveTS = getTime()
    if Controller.saving then
        saveRetries = saveRetries + 1
    else
        Controller.saving = true
        saveRetries = 0
    end
end

function Controller.reboot()
    protocol.mspRead(uiMsp.reboot)
    Controller.reload()
end

local function eepromWrite()
    protocol.mspRead(uiMsp.eepromWrite)
end

--- True once a save has been resent at least once, which the renderer says out
--- loud so a slow link does not look like a hang.
function Controller.retrying()
    return saveRetries > 0
end

--- Give up or resend a save that has not been acknowledged in time.
function Controller.tickSaving()
    if not Controller.saving then
        return
    end
    if saveTS + saveTimeout >= getTime() then
        return
    end
    if saveRetries < saveMaxRetries then
        Controller.savePage()
    else
        Controller.saving = false
        Controller.reload()
    end
end

--- What the flight controller can be asked to do, as against what the page in
--- front of you can. None of these read or write the open page, which is why
--- the LVGL renderer lists them on the main menu instead of behind a per-page
--- menu; the lcd renderer offers them in its popup, from either screen.
---
--- `t` is the label a 128x64 screen has room for. `title` is the same action
--- spelled out, for a renderer with the width to say it.
function Controller.fcActions()
    local actions = {}
    actions[#actions + 1] = { t = "reboot", title = "Reboot FC", f = Controller.reboot }
    actions[#actions + 1] = {
        t = "acc cal",
        title = "Calibrate Accelerometer",
        f = function()
            Controller.confirm("CONFIRM/acc_cal.lua")
        end,
    }
    if apiVersion >= 1.42 then
        actions[#actions + 1] = {
            t = "vtx tables",
            title = "Download VTX Tables",
            f = function()
                Controller.confirm("CONFIRM/vtx_tables.lua")
            end,
        }
    end
    if apiVersion >= 1.44 then
        actions[#actions + 1] = {
            t = "board info",
            title = "Download Board Info",
            f = function()
                Controller.confirm("CONFIRM/pwm.lua")
            end,
        }
    end
    return actions
end

--- The popup menu's contents. Which entries exist depends on the API version
--- and on whether a page is open, both of which are this side of the split;
--- where the box is drawn is not.
function Controller.menuActions()
    local actions = {}
    if Controller.state == status.pages then
        actions[#actions + 1] = { t = "save page", f = Controller.savePage }
        actions[#actions + 1] = { t = "reload", f = Controller.reload }
    end
    local fc = Controller.fcActions()
    for i = 1, #fc do
        actions[#actions + 1] = fc[i]
    end
    return actions
end

-- ============================================================================
-- Fields
-- ============================================================================

--- A field is editable when the FC has actually sent the bytes behind it. The
--- last of them is the one to test: a partial reply leaves the tail nil.
function Controller.isFieldEditable(f)
    local Page = Controller.Page
    return Page ~= nil and Page.values ~= nil and f.vals ~= nil and Page.values[f.vals[#f.vals]] ~= nil and not f.ro
end

--- Set a field and write the result back into Page.values, which stays the
--- single source of truth for the save path. The slots are not strictly
--- bytes, and masking them would break things: a field with one vals entry
--- keeps its whole value in that slot (vtx's Frequency, 5000-5999, which its
--- page splits into bytes itself in preSave), and a multi-byte field leaves
--- slot idx holding the value shifted down 8*(idx-1) bits -- the transport
--- bands every byte to 0xFF as it buffers, and rates' lshift+bor readback is
--- exact on the overlapped form. The value itself is clipped to the field's
--- range and snapped to its step, so a widget that hands over an arbitrary
--- number cannot put the page out of range.
function Controller.setFieldValue(f, value)
    local Page = Controller.Page
    local scale = f.scale or 1
    local mult = f.mult or 1
    f.value = clipValue(value, (f.min or 0) / scale, (f.max or 255) / scale)
    f.value = math.floor(f.value * scale / mult + 0.5) * mult / scale
    for idx = 1, #f.vals do
        Page.values[f.vals[idx]] = bit32.rshift(math.floor(f.value * scale + 0.5), (idx - 1) * 8)
    end
    if f.upd and Page.values then
        f.upd(Page)
    end
end

--- Step a field by one detent in either direction.
function Controller.incFieldValue(f, inc)
    Controller.setFieldValue(f, f.value + inc * (f.mult or 1) / (f.scale or 1))
end

function Controller.postEdit(f)
    if f.postEdit then
        f.postEdit(Controller.Page)
    end
end

-- ============================================================================
-- MSP
-- ============================================================================

function Controller.hasTelemetry()
    return getRSSI() ~= 0
end

local function requestPage()
    local Page = Controller.Page
    if Page.read and ((not Page.reqTS) or (Page.reqTS + requestTimeout <= getTime())) then
        Page.reqTS = getTime()
        protocol.mspRead(Page.read)
    end
end

local function processMspReply(cmd, rx_buf, err)
    local Page = Controller.Page
    if not Page or not rx_buf then
        return
    elseif cmd == Page.write then
        if Page.eepromWrite then
            eepromWrite()
        else
            Controller.reload()
        end
    elseif cmd == uiMsp.eepromWrite then
        if Page.reboot then
            Controller.reboot()
        end
        Controller.reload()
    elseif cmd == Page.read and err then
        -- The FC refused the command; asking again gets the same answer.
        -- Clearing `read` stops the retry loop, and doubles as the sign that
        -- this page is as loaded as it will ever be.
        Page.read = nil
        Page.fields = { { x = 6, y = radio.yMinLimit, value = "", ro = true } }
        Page.labels = { { x = 6, y = radio.yMinLimit, t = "N/A" } }
    elseif cmd == Page.read and #rx_buf > 0 then
        Page.values = rx_buf
        for i = 1, #Page.fields do
            if #Page.values >= Page.minBytes then
                local f = Page.fields[i]
                if f.vals then
                    f.value = 0
                    for idx = 1, #f.vals do
                        local raw_val = Page.values[f.vals[idx]] or 0
                        raw_val = bit32.lshift(raw_val, (idx - 1) * 8)
                        f.value = bit32.bor(f.value, raw_val)
                    end
                    local bits = #f.vals * 8
                    if f.min and f.min < 0 and bit32.btest(f.value, bit32.lshift(1, bits - 1)) then
                        f.value = f.value - (2 ^ bits)
                    end
                    f.value = f.value / (f.scale or 1)
                end
            end
        end
        if Page.postLoad then
            Page.postLoad(Page)
        end
    end
end

--- Ask for the open page's values if we do not have them yet. Skipped while a
--- save is in flight, so a retry is never raced by a fresh read.
function Controller.requestPageIfNeeded()
    if not Controller.Page.values and not Controller.saving then
        requestPage()
    end
end

--- Drain one frame of the link. Called last in every frame, from the renderer,
--- because the reply it dispatches may replace Controller.Page and the frame
--- that is being drawn must not see that happen halfway through.
function Controller.tick()
    mspProcessTxQ()
    processMspReply(mspPollReply())
end

return Controller
