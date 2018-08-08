SCRIPT_HOME = "/SCRIPTS/BF"

protocol = assert(loadScript(SCRIPT_HOME.."/protocols.lua"))()
radio = assert(loadScript(SCRIPT_HOME.."/radios.lua"))()

assert(loadScript(radio.preLoad))()
assert(loadScript(protocol.transport))()
assert(loadScript(SCRIPT_HOME.."/MSP/common.lua"))()

local run_ui = assert(loadScript(SCRIPT_HOME.."/ui.lua"))()

return { run=run_ui }
