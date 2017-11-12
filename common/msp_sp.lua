--
-- MSP/SPORT code
--

-- Protocol version
SPORT_MSP_VERSION = bit32.lshift(1,5)

SPORT_MSP_STARTFLAG = bit32.lshift(1,4)

-- Sensor ID used by the local LUA script
LOCAL_SENSOR_ID  = 0x0D

-- Sensor ID used by the MSP server (BF, CF, MW, etc...)
REMOTE_SENSOR_ID = 0x1B

REQUEST_FRAME_ID = 0x30
REPLY_FRAME_ID   = 0x32

-- Sequence number for next MSP/SPORT packet
local sportMspSeq = 0
local sportMspRemoteSeq = 0

local mspRxBuf = {}
local mspRxIdx = 1
local mspRxCRC = 0
local mspStarted = false
local mspLastReq = 0

-- Stats
mspRequestsSent    = 0
mspRepliesReceived = 0
mspPkRxed = 0
mspErrorPk = 0
mspStartPk = 0
mspOutOfOrder = 0
mspCRCErrors = 0

local function mspResetStats()
   mspRequestsSent    = 0
   mspRepliesReceived = 0
   mspPkRxed = 0
   mspErrorPk = 0
   mspStartPk = 0
   mspOutOfOrderPk = 0
   mspCRCErrors = 0
end

local mspTxBuf = {}
local mspTxIdx = 1
local mspTxCRC = 0

local mspTxPk = 0

local function mspSendSport(payload)

   local dataId = 0
   dataId = payload[1] + bit32.lshift(payload[2],8)

   local value = 0
   value = payload[3] + bit32.lshift(payload[4],8)
      + bit32.lshift(payload[5],16) + bit32.lshift(payload[6],24)

   local ret = sportTelemetryPush(LOCAL_SENSOR_ID, REQUEST_FRAME_ID, dataId, value)
   if ret then
      mspTxPk = mspTxPk + 1
   end
end

function mspProcessTxQ()

   if (#(mspTxBuf) == 0) then
      return false
   end

   if not sportTelemetryPush() then
      return true
   end

   local payload = {}
   payload[1] = sportMspSeq + SPORT_MSP_VERSION
   sportMspSeq = bit32.band(sportMspSeq + 1, 0x0F)

   if mspTxIdx == 1 then
      -- start flag
      payload[1] = payload[1] + SPORT_MSP_STARTFLAG
   end

   local i = 2
   while (i <= 6) do
      payload[i] = mspTxBuf[mspTxIdx]
      mspTxIdx = mspTxIdx + 1
      mspTxCRC = bit32.bxor(mspTxCRC,payload[i])
      i = i + 1
      if mspTxIdx > #(mspTxBuf) then
         break
      end
   end

   if i <= 6 then
      payload[i] = mspTxCRC
      i = i + 1

      -- zero fill
      while i <= 6 do
         payload[i] = 0
         i = i + 1
      end

      mspSendSport(payload)
      
      mspTxBuf = {}
      mspTxIdx = 1
      mspTxCRC = 0
      
      return false
   end
      
   mspSendSport(payload)
   return true
end

function mspSendRequest(cmd,payload)

   -- busy
   if #(mspTxBuf) ~= 0 then
      return nil
   end

   mspTxBuf[1] = #(payload)
   mspTxBuf[2] = bit32.band(cmd,0xFF)  -- MSP command

   for i=1,#(payload) do
      mspTxBuf[i+2] = payload[i]
   end
   
   mspLastReq = cmd
   mspRequestsSent = mspRequestsSent + 1
   return mspProcessTxQ()
end

local function mspReceivedReply(payload)

   mspPkRxed = mspPkRxed + 1
   
   local idx      = 1
   local head     = payload[idx]
   local err_flag = (bit32.band(head,0x20) ~= 0)
   idx = idx + 1

   if err_flag then
      -- error flag set
      mspStarted = false

      mspErrorPk = mspErrorPk + 1

      -- return error
      -- CRC checking missing

      --return payload[idx]
      return nil
   end
   
   local start = (bit32.band(head,0x10) ~= 0)
   local seq   = bit32.band(head,0x0F)

   if start then
      -- start flag set
      mspRxIdx = 1
      mspRxBuf = {}

      mspRxSize = payload[idx]
      mspRxCRC  = bit32.bxor(mspRxSize,mspLastReq)
      idx = idx + 1
      mspStarted = true
      
      mspStartPk = mspStartPk + 1

   elseif not mspStarted then
      mspOutOfOrder = mspOutOfOrder + 1
      return nil

   elseif bit32.band(sportMspRemoteSeq + 1, 0x0F) ~= seq then
      mspOutOfOrder = mspOutOfOrder + 1
      mspStarted = false
      return nil
   end

   while (idx <= 6) and (mspRxIdx <= mspRxSize) do
      mspRxBuf[mspRxIdx] = payload[idx]
      mspRxCRC = bit32.bxor(mspRxCRC,payload[idx])
      mspRxIdx = mspRxIdx + 1
      idx = idx + 1
   end

   if idx > 6 then
      sportMspRemoteSeq = seq
      return true
   end

   -- check CRC
   if mspRxCRC ~= payload[idx] then
      mspStarted = false
      mspCRCErrors = mspCRCErrors + 1
      return nil
   end

   mspRepliesReceived = mspRepliesReceived + 1
   mspStarted = false
   return mspRxBuf
end

function mspPollReply()
   while true do
      local sensorId, frameId, dataId, value = sportTelemetryPop()
      if sensorId == REMOTE_SENSOR_ID and frameId == REPLY_FRAME_ID then

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

         local ret = mspReceivedReply(payload)
         if type(ret) == "table" then
            return mspLastReq,ret
         end
      else
         break
      end
   end

   return nil
end

function mspGetLastReqValue()
   return mspLastReq
end

--
-- End of MSP/SPORT code
--
