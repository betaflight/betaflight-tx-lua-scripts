local supportedProtocols =
{
    smartPort =
    {
        mspTransport    = "MSP/sp.lua",
        push            = sportTelemetryPush,
        maxTxBufferSize = 6,
        maxRxBufferSize = 6,
        saveMaxRetries  = 2,
        saveTimeout     = 500,
        cms             = {},
    },
    crsf =
    {
        mspTransport    = "MSP/crsf.lua",
        cmsTransport    = "CMS/crsf.lua",
        push            = crossfireTelemetryPush,
        maxTxBufferSize = 8,
        maxRxBufferSize = 58,
        saveMaxRetries  = 2,
        saveTimeout     = 150,
        cms             = {},
    }
}

local function getProtocol()
    if supportedProtocols.smartPort.push() ~= nil then
        return supportedProtocols.smartPort
    elseif supportedProtocols.crsf.push() ~= nil then
        return supportedProtocols.crsf
    end
end

local protocol = assert(getProtocol(), "Telemetry protocol not supported!")

return protocol
