local MSP_SET_BATTERY_CONFIG = 210
local MSP_BATTERY_CONFIG = 211

local batteryConfig = {
    warningVoltage = 0,
    minVoltage = 0,
    batteryType = 0
}

local function processMspReply(cmd, payload, err)
    if cmd == MSP_BATTERY_CONFIG and not err then
        batteryConfig.warningVoltage = payload[1]
        batteryConfig.minVoltage = payload[2]
        batteryConfig.batteryType = payload[3]
    end
end

local function getBatteryConfig()
    protocol.mspRead(MSP_BATTERY_CONFIG)
    mspProcessTxQ()
    processMspReply(mspPollReply())
end

local function setBatteryConfig()
    local values = {
        batteryConfig.warningVoltage,
        batteryConfig.minVoltage,
        batteryConfig.batteryType
    }
    protocol.mspWrite(MSP_SET_BATTERY_CONFIG, values)
    mspProcessTxQ()
    processMspReply(mspPollReply())
end

local function init()
    getBatteryConfig()
end

local function run(event)
    if event == EVT_VIRTUAL_ENTER then
        setBatteryConfig()
    end
    return 0
end

return { init = init, run = run }
