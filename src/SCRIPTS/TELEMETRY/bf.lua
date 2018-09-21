SCRIPT_HOME = "/SCRIPTS/BF"

-- Change this to match the API version of the firmware you are using
-- (you can have multiple copies of this script with different values
-- for API_VERSION, and select different versions for different models
-- on your TX)
-- Version mapping:
--  1.041: Betaflight 4.0 and newer
-- <1.041: Betaflight 3.5 and older
API_VERSION = 1.040

protocol = assert(loadScript(SCRIPT_HOME.."/protocols.lua"))()
radio = assert(loadScript(SCRIPT_HOME.."/radios.lua"))()

assert(loadScript(radio.preLoad))()
assert(loadScript(protocol.transport))()
assert(loadScript(SCRIPT_HOME.."/MSP/common.lua"))()

local run_ui = assert(loadScript(SCRIPT_HOME.."/ui.lua"))()
local background = assert(loadScript(SCRIPT_HOME.."/background.lua"))()

local MENU_TIMESLICE = 100

local lastMenuEvent = 0

function run(event)
  lastMenuEvent = getTime()

  run_ui(event)
end

function run_bg()
  if lastMenuEvent + MENU_TIMESLICE < getTime() then
    background.run_bg()
  end
end

return { init=background.init, run=run, background=run_bg }
