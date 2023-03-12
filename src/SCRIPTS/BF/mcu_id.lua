local MSP_UID = 160

local MCUIdReceived = false

local lastRunTS = 0
local INTERVAL = 100

local function processMspReply(cmd, payload, err)
    if cmd == MSP_UID and not err then
        local i = 1
        local id = ""
        for j = 1, 3 do
            local s = ""
            for k = 1, 4 do
                s = string.format("%02x", payload[i])..s
                i = i + 1
            end
            id = id..s
        end
        mcuId = id
        MCUIdReceived = true
    end
end

local function getMCUId()
    if lastRunTS + INTERVAL < getTime() then
        lastRunTS = getTime()
        if not MCUIdReceived then
            protocol.mspRead(MSP_UID)
        end
    end
    mspProcessTxQ()
    processMspReply(mspPollReply())
    return MCUIdReceived
end

return { f = getMCUId, t = "Waiting for device ID" }
