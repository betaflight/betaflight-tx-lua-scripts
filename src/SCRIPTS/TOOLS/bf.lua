local toolName = "TNS|Betaflight setup|TNE"
SCRIPT_HOME = "/SCRIPTS/BF"

apiVersion = 0
isTelemetryScript = false

protocol = assert(loadScript(SCRIPT_HOME.."/protocols.lua"))()
radio = assert(loadScript(SCRIPT_HOME.."/radios.lua"))()

assert(loadScript(radio.preLoad))()
assert(loadScript(protocol.transport))()
assert(loadScript(SCRIPT_HOME.."/MSP/common.lua"))()

local run_ui = assert(loadScript(SCRIPT_HOME.."/ui.lua"))()

return { run=run_ui }
