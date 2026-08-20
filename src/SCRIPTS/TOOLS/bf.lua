local toolName = "TNS|Betaflight setup|TNE"
chdir("/SCRIPTS/BF")

apiVersion = 0
mcuId = nil

-- PERCENT_SIZE arrived in 2.11.4, in the same batch as the page header's
-- navigation buttons and the layout constants ui/lvgl.lua is built on, so it
-- is an honest gate for the whole renderer rather than for the lvgl table
-- alone -- that has existed since 2.11.0. A colour radio below 2.11.4 falls
-- through to ui/lcd.lua and keeps the rendering it has always had; there is no
-- version-nag screen.
local useLvgl = (lvgl ~= nil and lvgl.PERCENT_SIZE ~= nil)

-- Forward-declared so init() can drop itself once it has run: the table this
-- file returns stays on the standalone script's Lua stack for the whole
-- session, and with it every upvalue init() closed over.
local M = {}

-- A cold card has no bytecode yet, and parsing the tree on demand runs a
-- 128x64 radio out of heap. COMPILE/compile.lua walks the manifest one file
-- per frame instead; it is a complete tool in itself, so nothing below this
-- point loads until it has finished and the tool is opened again.
local scriptsCompiled = assert(loadScript("COMPILE/scripts_compiled.lua"))()
if not scriptsCompiled then
    M.run = assert(loadScript("COMPILE/compile.lua"))()
    -- compile.lua draws with lcd.*, and the firmware only allows that when the
    -- script has not claimed an LVGL layout. Report false for this launch; the
    -- next one picks the real backend.
    M.useLvgl = false
    return M
end

local loader = assert(loadScript("loader.lua"))()

local UI

--- Called once, before the first frame. Everything loads here rather than at
--- chunk scope so the work happens after the tool is on screen.
local function init()
    -- Stand in for a flight controller when there is none. Nothing loads
    -- unless getVersion() says this is the simulator, so a radio never runs
    -- any of it, and loadScript returns nil on a card that does not carry
    -- the mock. It goes first because protocols.lua asserts when it finds no
    -- telemetry module, and returns a second pass to run once MSP/common.lua
    -- has defined the globals it wants to replace.
    local applyMock
    local _, rv = getVersion()
    if string.sub(rv, -5) == "-simu" then
        local mock = loadScript("/SCRIPTS/BFSimulator/bfsimulator.lua")
        if mock then
            applyMock = mock()
        end
    end

    protocol = loader("protocols.lua")
    radio = loader("radios.lua").msp
    loader(protocol.mspTransport)
    loader("MSP/common.lua")
    features = loader("features.lua")

    if applyMock then
        applyMock()
    end

    UI = loader(useLvgl and "ui/lvgl.lua" or "ui/lcd.lua")
    if UI.init then
        UI.init()
    end
    M.init = nil
end

local function run(event, touchState)
    return UI.render(event, touchState)
end

M.init = init
M.run = run
M.useLvgl = useLvgl
return M
