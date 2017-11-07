-- load msp.lua
assert(loadScript("/SCRIPTS/BF/msp_sp.lua"))()

SetupPages = {
   {
      title = "PIDs",
      text = {
         { t = "P",      x =  48,  y = 14 },
         { t = "I",      x =  76,  y = 14 },
         { t = "D",      x = 104,  y = 14 },
         { t = "ROLL",   x =   1,  y = 26 },
         { t = "PITCH",  x =   1,  y = 36 },
         { t = "YAW",    x =   1,  y = 46 },
      },
      fields = {
         -- P
         { x = 42, y = 26, i =  1 },
         { x = 42, y = 36, i =  4 },
         { x = 42, y = 46, i =  7 },
         -- I
         { x = 70, y = 26, i =  2 },
         { x = 70, y = 36, i =  5 },
         { x = 70, y = 46, i =  8 },
         -- D
         { x = 98, y = 26, i =  3 },
         { x = 98, y = 36, i =  6 },
         --{ x = 98, y = 46, i =  9 },
      },
   },
   {
      title = "Rates",
      text = {
         { t = "RC",     x =  41,  y = 11, to = SMLSIZE },
         { t = "Rate",   x =  41,  y = 18, to = SMLSIZE },
         { t = "Super",  x =  67,  y = 11, to = SMLSIZE },
         { t = "Rate",   x =  67,  y = 18, to = SMLSIZE },
         { t = "RC",     x =  97,  y = 11, to = SMLSIZE },
         { t = "Expo",   x =  97,  y = 18, to = SMLSIZE },
         { t = "ROLL",   x =   1,  y = 26 },
         { t = "PITCH",  x =   1,  y = 36 },
         { t = "YAW",    x =   1,  y = 46 },
      },
      fields = {
         -- RC Rate
         { x = 42, y = 31, i =  1 },
         { x = 42, y = 46, i = 12 },
         -- Super Rate
         { x = 70, y = 26, i =  3 },
         { x = 70, y = 36, i =  4 },
         { x = 70, y = 46, i =  5 },
         -- RC Expo
         { x = 98, y = 31, i =  2 },
         { x = 98, y = 46, i = 11 },
      },
   },
   {
      title = "VTX",
      text = {},
      fields = {
         -- Super Rate
         { t = "Band", x = 1, y = 12, sp = 34, i=2, min=1, max=5, table = { "A", "B", "E", "F", "R" } },
         { t = "Ch",   x = 1, y = 22, sp = 34, i=3, min=1, max=8 },
         { t = "Pw",   x = 1, y = 32, sp = 34, i=4, min=1 },
         { t = "Pit",  x = 1, y = 42, sp = 34, i=5, min=0, max=1, table = { [0]="OFF", "ON" } },
         { t = "Dev",  x = 60, y = 12, sp = 34, i=1, ro=true, table = {[3]="SA",[4]="Tramp",[255]="None"} },
         { t = "Freq", x = 60, y = 22, sp = 34, i="f", ro=true },
      },
   }
}

MenuBox = { x=1, y=10, w=100, x_offset=36, h_line=10, h_offset=3 }
SaveBox = { x=20, y=12, w=100, x_offset=4,  h=30, h_offset=5 }
NoTelem = { 36, 55, "No Telemetry", BLINK }

-- ---------------------------------------
-- BACKGROUND PROCESS
-- ---------------------------------------

local INTERVAL          = 100        -- 100 = 1 second, 200 = 2 seconds, ...
local MSP_SET_RTC       = 246
local MSP_TX_INFO       = 186
local sensorName        = "VFAS"

local lastRunTS
local oldSensorValue
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
    oldSensorValue = 0
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

        if type(newSensorValue) == "number" then

            -- Send datetime when the telemetry connection is available
            -- assuming when sensor value higher than 0 there is an telemetry connection
            -- only send datetime one time after telemetry connection became available 
            -- or when connection is restored after e.g. lipo refresh
            if oldSensorValue == 0 and newSensorValue > 0 then
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
            end

            oldSensorValue = newSensorValue
        end


        -- ------------------------------------
        -- SEND RSSI VALUE
        -- ------------------------------------

        if mspMsgQueued == false then
            local rssi, alarm_low, alarm_crit = getRSSI()
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

--
-- END
--

local run_ui = assert(loadScript("/SCRIPTS/BF/ui.lua"))()
return { init=init, run=run_ui, background=run_bg }
