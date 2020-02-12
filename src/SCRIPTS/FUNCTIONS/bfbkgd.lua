chdir("/SCRIPTS/BF")
apiVersion = 0
protocol = assert(loadScript("protocols.lua"))()
assert(loadScript(protocol.transport))()
assert(loadScript("MSP/common.lua"))()
local background = assert(loadScript("background.lua"))()

return { run=background }
