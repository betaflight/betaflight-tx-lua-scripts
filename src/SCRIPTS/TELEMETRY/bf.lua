SCRIPT_HOME = "/SCRIPTS/BF"

apiVersion = 0
isTelemetryScript = true

protocol = assert(loadScript(SCRIPT_HOME.."/protocols.lua"))()
radio = assert(loadScript(SCRIPT_HOME.."/radios.lua"))()

assert(loadScript(SCRIPT_HOME.."/pages.lua"))()
assert(loadScript(protocol.transport))()
assert(loadScript(SCRIPT_HOME.."/MSP/common.lua"))()

local run_ui = assert(loadScript(SCRIPT_HOME.."/ui.lua"))()
local background = assert(loadScript(SCRIPT_HOME.."/background.lua"))()

local MENU_TIMESLICE = 100

local lastMenuEvent = 0

local function run(event)
    if background then
        background = nil
        collectgarbage()
    end
    lastMenuEvent = getTime()
    run_ui(event)
end

local function run_bg()
    if lastMenuEvent + MENU_TIMESLICE < getTime() then
        if not background then
            background = assert(loadScript(SCRIPT_HOME.."/background.lua"))()
            collectgarbage()
        end
        background()
    end
end

return { run=run, background=run_bg }
