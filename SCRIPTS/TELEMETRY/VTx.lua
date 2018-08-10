SCRIPT_HOME = "/SCRIPTS/TELEMETRY/VTx"

LOCAL_SENSOR_ID  = 0x0D
SMARTPORT_REMOTE_SENSOR_ID = 0x1B
FPORT_REMOTE_SENSOR_ID = 0x00
REQUEST_FRAME_ID = 0x30
REPLY_FRAME_ID   = 0x32

MenuBox = { x=15, y=12, w=100, x_offset=36, h_line=8, h_offset=3 }
SaveBox = { x=15, y=12, w=100, x_offset=4,  h=30, h_offset=5 }
NoTelem = { 30, 55, "No Telemetry", BLINK }

protocol = {
  rssi            = function() return getValue("RSSI") end,
  exitFunc        = function() return 0 end,
  stateSensor     = "Tmp1",
  push            = sportTelemetryPush,
  maxTxBufferSize = 6,
  maxRxBufferSize = 6,
  saveMaxRetries  = 2,
  saveTimeout     = 300
}

protocol.mspSend = function(payload)
    local dataId = 0
    dataId = payload[1] + bit32.lshift(payload[2],8)
    local value = 0
    value = payload[3] + bit32.lshift(payload[4],8)
        + bit32.lshift(payload[5],16) + bit32.lshift(payload[6],24)
    return sportTelemetryPush(LOCAL_SENSOR_ID, REQUEST_FRAME_ID, dataId, value)
end

protocol.mspRead = function(cmd)
    return mspSendRequest(cmd, {})
end

protocol.mspWrite = function(cmd, payload)
    return mspSendRequest(cmd, payload)
end

protocol.mspPoll = function()
    local sensorId, frameId, dataId, value = sportTelemetryPop()
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

assert(loadScript(SCRIPT_HOME.."/common.luac", "T"))()
collectgarbage()

local run_ui = assert(loadScript(SCRIPT_HOME.."/ui.luac", "T"))()
collectgarbage()

local background = assert(loadScript(SCRIPT_HOME.."/background.luac", "T"))()
collectgarbage()

local MENU_TIMESLICE = 100
local lastMenuEvent = 0

function run(event)
  lastMenuEvent = getTime()
  collectgarbage()
  run_ui(event)
end

function run_bg()
  if lastMenuEvent + MENU_TIMESLICE < getTime() then
    background.run_bg()
    collectgarbage()
  end
end

return { init=background.init, run=run, background=run_bg }
