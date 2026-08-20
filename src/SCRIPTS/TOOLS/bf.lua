local toolName = "TNS|Betaflight setup|TNE"
chdir("/SCRIPTS/BF")

apiVersion = 0
mcuId = nil

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
    return M
end

local loader = assert(loadScript("loader.lua"))()

local UI

--- Called once, before the first frame. Everything loads here rather than at
--- chunk scope so the work happens after the tool is on screen.
local function init()
    protocol = loader("protocols.lua")
    radio = loader("radios.lua").msp
    loader(protocol.mspTransport)
    loader("MSP/common.lua")
    features = loader("features.lua")

    UI = loader("ui/lcd.lua")
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
return M
