SCRIPT_HOME = "/SCRIPTS/BF"
apiVersion = 0
protocol = assert(loadScript(SCRIPT_HOME.."/protocols.lua"))()
assert(loadScript(protocol.transport))()
assert(loadScript(SCRIPT_HOME.."/MSP/common.lua"))()
local background = assert(loadScript(SCRIPT_HOME.."/background.lua"))()

return { run=background }
