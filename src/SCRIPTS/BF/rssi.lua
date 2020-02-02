local MSP_SET_TX_INFO = 186
local MSP_TX_INFO = 187

local RSSI_SOURCE_NONE = 0
local RSSI_SOURCE_MSP = 4

local rssiSourceReceived = false
local rssiSource = RSSI_SOURCE_NONE
local lastRunTS = 0
local INTERVAL = 50

local function processMspReply(cmd,rx_buf)
    if cmd == MSP_TX_INFO and #rx_buf >= 1 then
        rssiSource = rx_buf[1]
        rssiSourceReceived = true
    end
end

local function rssiTask()
    if lastRunTS == 0 or lastRunTS + INTERVAL < getTime() then
        if not rssiSourceReceived then
            protocol.mspRead(MSP_TX_INFO)
        elseif rssiSource == RSSI_SOURCE_NONE or rssiSource == RSSI_SOURCE_MSP then
            local rssi, alarm_low, alarm_crit = getRSSI()
            -- Scale the [0, 99] RSSI values to [0, 255]
            rssi = rssi * 255 / 99
            if rssi > 255 then
                rssi = 255
            end

            local values = {}
            values[1] = rssi

            protocol.mspWrite(MSP_SET_TX_INFO, values)
        end
        lastRunTS = getTime()
    end

    mspProcessTxQ()

    processMspReply(mspPollReply())

    return rssiSource == RSSI_SOURCE_NONE or rssiSource == RSSI_SOURCE_MSP
end

return rssiTask
