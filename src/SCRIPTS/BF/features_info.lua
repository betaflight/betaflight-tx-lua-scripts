local MSP_GPS_CONFIG = 135
local MSP_VTX_CONFIG = 88

local isGpsRead = false
local isVtxRead = true -- Checking VTX is done in `vtx_tables.lua`

local lastRunTS = 0
local INTERVAL = 100

local returnTable = {
    f = nil,
    t = "",
}

local function processMspReply(cmd, payload, err)
    local isOkay = not err
    if cmd == MSP_GPS_CONFIG then
        isGpsRead = true
        local providerSet = payload[1] ~= 0
        features.gps = isOkay and providerSet
    elseif cmd == MSP_VTX_CONFIG then
        isVtxRead = true
        local vtxTableAvailable = payload[12] ~= 0
        features.vtx = isOkay and vtxTableAvailable
    end
end

local function updateFeatures()
    if lastRunTS + INTERVAL < getTime() then
        lastRunTS = getTime()
        local cmd
        if not isGpsRead then
            cmd = MSP_GPS_CONFIG
            returnTable.t = "Checking GPS..."
        elseif not isVtxRead then
            cmd = MSP_VTX_CONFIG
            returnTable.t = "Checking VTX..."
        end
        if cmd then
            protocol.mspRead(cmd)
        else
            return true
        end
    end
    mspProcessTxQ()
    processMspReply(mspPollReply())
    return false
end

returnTable.f = updateFeatures

return returnTable
