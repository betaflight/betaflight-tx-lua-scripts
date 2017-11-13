SCRIPT_HOME = "/SCRIPTS/BF"

assert(loadScript(SCRIPT_HOME.."/MSP/common.lua"))()

local INTERVAL          = 50         -- in 1/100th seconds
local MSP_SET_RTC       = 246
local MSP_TX_INFO       = 186
local sensorName        = "Tmp1"     -- T1 is never 0 in Betaflight

local lastRunTS
local timeIsSet = false
local sensorId
local mspMsgQueued = false

local function getTelemetryId(name)
    local field = getFieldInfo(name)
    if field then
      return field['id']
    else
      return -1
    end
end

local function init()
    sensorId = getTelemetryId(sensorName)
    lastRunTS = 0
end

local function run_bg()
    -- run in intervals
    if lastRunTS == 0 or lastRunTS + INTERVAL < getTime() then

        mspMsgQueued = false

        -- ------------------------------------
        -- SYNC DATE AND TIME
        -- ------------------------------------

        -- get sensor value
        local newSensorValue = getValue(sensorId)

        if not timeIsSet and type(newSensorValue) == "number" and newSensorValue > 0 then
            -- Send datetime when the telemetry connection is available
            -- assuming when sensor value higher than 0 there is an telemetry connection
            -- only send datetime one time after telemetry connection became available 
            -- or when connection is restored after e.g. lipo refresh
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

            -- send msp message
            mspSendRequest(MSP_SET_RTC, values)
            mspMsgQueued = true

            timeIsSet = true
        else
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
            mspSendRequest(MSP_TX_INFO, values)
            mspMsgQueued = true
        end

        lastRunTS = getTime()
    end

    -- process queue
    mspProcessTxQ()

end

return { init=init, run_bg=run_bg }
