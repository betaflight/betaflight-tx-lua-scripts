local supportedProtocols =
{
    smartPort =
    {
        mspTransport    = "MSP/sp.lua",
        rssi            = function() return getValue("RSSI") end,
        stateSensor     = "Tmp1",
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
        rssi            = function() return getValue("TQly") end,
        stateSensor     = "1RSS",
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
