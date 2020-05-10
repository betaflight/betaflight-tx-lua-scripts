local toolName = "TNS|Betaflight CMS|TNE"
chdir("/SCRIPTS/BF")

apiVersion = 0

local cms = { run = nil, init = nil }
local scriptsCompiled = assert(loadScript("COMPILE/scripts_compiled.lua"))()

if scriptsCompiled then
    protocol = assert(loadScript("protocols.lua"))()
    local cmsTransport = assert(protocol.cmsTransport, "Telemetry protocol not supported!")
    radio = assert(loadScript("radios.lua"))().cms
    assert(loadScript(cmsTransport))()
    assert(loadScript("CMS/common.lua"))()
    cms = assert(loadScript("cms.lua"))()
else
    cms = { run = assert(loadScript("COMPILE/compile.lua"))() }
end

return cms
