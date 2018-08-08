SCRIPT_HOME = "/SCRIPTS/TELEMETRY/VTx"

MenuBox = { x=15, y=12, w=100, x_offset=36, h_line=8, h_offset=3 }
SaveBox = { x=15, y=12, w=100, x_offset=4,  h=30, h_offset=5 }
NoTelem = { 30, 55, "No Telemetry", BLINK }

protocol = assert(loadScript(SCRIPT_HOME.."/protocols.luac", "T"))()
assert(loadScript(protocol.transport, "T"))()
collectgarbage()

assert(loadScript(SCRIPT_HOME.."/common.luac", "T"))()
collectgarbage()

local run_ui = assert(loadScript(SCRIPT_HOME.."/ui.luac", "T"))()
local background = assert(loadScript(SCRIPT_HOME.."/background.luac", "T"))()

local MENU_TIMESLICE = 100

local lastMenuEvent = 0

function run(event)
  lastMenuEvent = getTime()

  collectgarbage()
  run_ui(event)
end

function run_bg()
  collectgarbage()
  if lastMenuEvent + MENU_TIMESLICE < getTime() then
    background.run_bg()
  end
end

return { init=background.init, run=run, background=run_bg }
