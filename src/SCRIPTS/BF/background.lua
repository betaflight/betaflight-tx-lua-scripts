local INTERVAL          = 50         -- in 1/100th seconds
local MSP_SET_RTC       = 246
local MSP_TX_INFO       = 186

local lastRunTS
local sensorId = -1
local timeIsSet = false
local mspMsgQueued = false

local function getSensorValue()
    if sensorId == -1 then
        local sensor = getFieldInfo(protocol.stateSensor)
        if type(sensor) == "table" then
            sensorId = sensor['id'] or -1
        end
    end
    return getValue(sensorId)
end

local function modelActive(sensorValue)
    return type(sensorValue) == "number" and sensorValue > 0
end

local function init()
    lastRunTS = 0
end

local function run_bg()
    -- run in intervals

    if lastRunTS == 0 or lastRunTS + INTERVAL < getTime() then
        mspMsgQueued = false
        -- ------------------------------------
        -- SYNC DATE AND TIME
        -- ------------------------------------
        local sensorValue = getSensorValue()

        if not timeIsSet and modelActive(sensorValue) then
            -- Send datetime when the telemetry connection is available
            -- assuming when sensor value higher than 0 there is an telemetry connection
            -- only send datetime one time after telemetry connection became available
            -- or when connection is restored after e.g. lipo refresh

            if API_VERSION < 1.041 then
                -- format: year (16) / month (8) / day (8) / hour (8) / min (8) / sec (8)
                local now = getDateTime()
                local year = now.year;

                values = {}
                values[1] = bit32.band(year, 0xFF)
                year = bit32.rshift(year, 8)
                values[2] = bit32.band(year, 0xFF)
                values[3] = now.mon
                values[4] = now.day
                values[5] = now.hour
                values[6] = now.min
                values[7] = now.sec
            else
                -- format: seconds after the epoch (32) / milliseconds (16)
                local now = getRtcTime()

                values = {}

                for i = 1, 4 do
                    values[i] = bit32.band(now, 0xFF)
                    now = bit32.rshift(now, 8)
                end

                values[5] = 0 -- we don't have milliseconds
                values[6] = 0
            end

            -- send msp message
            protocol.mspWrite(MSP_SET_RTC, values)
            mspMsgQueued = true

            timeIsSet = true
        elseif not modelActive(sensorValue) then
            timeIsSet = false
        end


        -- ------------------------------------
        -- SEND RSSI VALUE
        -- ------------------------------------

        if mspMsgQueued == false then
            local rssi, alarm_low, alarm_crit = getRSSI()
            -- Scale the [0, 85] (empirical) RSSI values to [0, 255]
            rssi = rssi * 3
            if rssi > 255 then
                rssi = 255
            end

            values = {}
            values[1] = rssi

            -- send msp message
            protocol.mspWrite(MSP_TX_INFO, values)
            mspMsgQueued = true
        end

        lastRunTS = getTime()
    end

    -- process queue
    mspProcessTxQ()

end

return { init=init, run_bg=run_bg }
