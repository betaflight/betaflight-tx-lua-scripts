local LOCAL_SENSOR_ID  = 0x0D
local SMARTPORT_REMOTE_SENSOR_ID = 0x1B
local FPORT_REMOTE_SENSOR_ID = 0x00
local REQUEST_FRAME_ID = 0x30
local REPLY_FRAME_ID   = 0x32

local lastSensorId, lastFrameId, lastDataId, lastValue

protocol.mspSend = function(payload)
    local dataId = payload[1] + bit32.lshift(payload[2],8)
    local value = payload[3] + bit32.lshift(payload[4],8)
        + bit32.lshift(payload[5],16) + bit32.lshift(payload[6],24)
    return protocol.push(LOCAL_SENSOR_ID, REQUEST_FRAME_ID, dataId, value)
end

protocol.mspRead = function(cmd)
    return mspSendRequest(cmd, {})
end

protocol.mspWrite = function(cmd, payload)
    return mspSendRequest(cmd, payload)
end

-- Discards duplicate data from lua input buffer
local function smartPortTelemetryPop()
    while true do
        local sensorId, frameId, dataId, value = sportTelemetryPop()
        if not sensorId then
            return nil
        elseif (lastSensorId == sensorId) and (lastFrameId == frameId) and (lastDataId == dataId) and (lastValue == value) then
            -- Keep checking
        else
            lastSensorId = sensorId
            lastFrameId = frameId
            lastDataId = dataId
            lastValue = value
            return sensorId, frameId, dataId, value
        end
    end
end

protocol.mspPoll = function()
    local sensorId, frameId, dataId, value = smartPortTelemetryPop()
    if (sensorId == SMARTPORT_REMOTE_SENSOR_ID or sensorId == FPORT_REMOTE_SENSOR_ID) and frameId == REPLY_FRAME_ID then
        local payload = {}
        payload[1] = bit32.band(dataId,0xFF)
        dataId = bit32.rshift(dataId,8)
        payload[2] = bit32.band(dataId,0xFF)
        payload[3] = bit32.band(value,0xFF)
        value = bit32.rshift(value,8)
        payload[4] = bit32.band(value,0xFF)
        value = bit32.rshift(value,8)
        payload[5] = bit32.band(value,0xFF)
        value = bit32.rshift(value,8)
        payload[6] = bit32.band(value,0xFF)
        return mspReceivedReply(payload)
    end
    return nil
end
