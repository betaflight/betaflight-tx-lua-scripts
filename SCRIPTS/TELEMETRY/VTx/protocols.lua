local supportedProtocols =
{
    smartPort =
    {
        transport       = SCRIPT_HOME.."/sp.luac",
        rssi            = function() return getValue("RSSI") end,
        exitFunc        = function() return 0 end,
        stateSensor     = "Tmp1",
        push            = sportTelemetryPush,
        maxTxBufferSize = 6,
        maxRxBufferSize = 6,
        saveMaxRetries  = 2,
        saveTimeout     = 300
    },
    crsf =
    {
        transport       = SCRIPT_HOME.."/crsf.luac",
        rssi            = function() return getValue("TQly") end,
        --exitFunc        = function() return "/crossfire.luac" end,
        exitFunc        = function() return 0 end,
        stateSensor     = "1RSS",
        push            = crossfireTelemetryPush,
        maxTxBufferSize = 8,
        maxRxBufferSize = 58,
        saveMaxRetries  = 2,
        saveTimeout     = 150
    }
}

function getProtocol()
    if supportedProtocols.smartPort.push() then
        return supportedProtocols.smartPort
    elseif supportedProtocols.crsf.push() then
        return supportedProtocols.crsf
    end
end

local protocol = getProtocol()

if not protocol then
    error("Telemetry protocol not supported!")
end

return protocol
