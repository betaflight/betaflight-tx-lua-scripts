SCRIPT_HOME = "/SCRIPTS/TELEMETRY/VTx"

PageFiles = {
  "vtx.lua"
}

MenuBox = { x=15, y=12, w=100, x_offset=36, h_line=8, h_offset=3 }
SaveBox = { x=15, y=12, w=100, x_offset=4,  h=30, h_offset=5 }
NoTelem = { 30, 55, "No Telemetry", BLINK }

protocol = assert(loadScript(SCRIPT_HOME.."/protocols.lua"))()
assert(loadScript(protocol.transport))()
collectgarbage()

assert(loadScript(SCRIPT_HOME.."/common.lua"))()
collectgarbage()

local run_ui = assert(loadScript(SCRIPT_HOME.."/ui.lua"))()
local background = assert(loadScript(SCRIPT_HOME.."/background.lua"))()

local MENU_TIMESLICE = 100

local lastMenuEvent = 0

function run(event)
  lastMenuEvent = getTime()

  collectgarbage()
  run_ui(event)
end

function run_bg()
  if lastMenuEvent + MENU_TIMESLICE < getTime() then
    background.run_bg()
  end
end

return { init=background.init, run=run, background=run_bg }
