local dataInitialised = false
local data_init = nil
local rssiEnabled = true
local rssiTask = nil

local function modelActive()
    return getValue(protocol.stateSensor) > 0
end

local function run_bg()
    if modelActive() then
        -- Send data when the telemetry connection is available
        -- assuming when sensor value higher than 0 there is an telemetry connection
        if not dataInitialised then
            if not data_init then
                data_init = assert(loadScript("data_init.lua"))()
            end

            dataInitialised = data_init.f()

            if dataInitialised then
                data_init = nil

                collectgarbage()
            end
        elseif rssiEnabled and apiVersion >= 1.037 then
            if not rssiTask then
                rssiTask = assert(loadScript("rssi.lua"))()
            end

            rssiEnabled = rssiTask()

            if not rssiEnabled then
                rssiTask = nil

                collectgarbage()
            end
        end
    else
        dataInitialised = false
        rssiEnabled = true
        if data_init or rssiTask then
            data_init = nil
            rssiTask = nil
            collectgarbage()
        end
    end
end

return run_bg
