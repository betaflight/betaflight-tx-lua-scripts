local toolName = "TNS|Betaflight setup|TNE"
chdir("/SCRIPTS/BF")

apiVersion = 0

protocol = assert(loadScript("protocols.lua"))()
radio = assert(loadScript("radios.lua"))()

assert(loadScript(protocol.transport))()
assert(loadScript("MSP/common.lua"))()

local run_ui = assert(loadScript("ui.lua"))()

return { run=run_ui }
