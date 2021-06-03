local MSP_API_VERSION = 1

local apiVersionReceived = false
local lastRunTS = 0
local INTERVAL = 50

local function processMspReply(cmd,rx_buf)
    if cmd == MSP_API_VERSION and #rx_buf >= 3 then
        apiVersion = rx_buf[2] + rx_buf[3] / 1000
        apiVersionReceived = true
    end
end

local function getApiVersion()
    if lastRunTS == 0 or lastRunTS + INTERVAL < getTime() then
        protocol.mspRead(MSP_API_VERSION)
        lastRunTS = getTime()
    end

    mspProcessTxQ()
    processMspReply(mspPollReply())

    return apiVersionReceived
end

return { f = getApiVersion, t = "Waiting for API version" }
