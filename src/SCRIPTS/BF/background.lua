local apiVersionReceived = false
local timeIsSet = false
local getApiVersion, setRtc, rssiTask
local rssiEnabled = true

local function modelActive()
    return getValue(protocol.stateSensor) > 0
end

local function run_bg()
    if modelActive() then
        -- Send data when the telemetry connection is available
        -- assuming when sensor value higher than 0 there is an telemetry connection
        if not apiVersionReceived then
            getApiVersion = getApiVersion or assert(loadScript("api_version.lua"))()
            apiVersionReceived = getApiVersion.f()
            if apiVersionReceived then
                getApiVersion = nil
                collectgarbage()
            end
        elseif not timeIsSet then
            setRtc = setRtc or assert(loadScript("rtc.lua"))()
            timeIsSet = setRtc.f()
            if timeIsSet then
                setRtc = nil
                collectgarbage()
            end
        elseif rssiEnabled and apiVersion >= 1.037 then
            rssiTask = rssiTask or assert(loadScript("rssi.lua"))()
            rssiEnabled = rssiTask()
            if not rssiEnabled then
                rssiTask = nil
                collectgarbage()
            end
        end
    else
        apiVersionReceived = false
        timeIsSet = false
        rssiEnabled = true
        if getApiVersion or setRtc or rssiTask then
            getApiVersion = nil
            setRtc = nil
            rssiTask = nil
            collectgarbage()
        end
    end
end

return run_bg
