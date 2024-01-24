local MSP_GPS_CONFIG = 135
local MSP_VTX_CONFIG = 88
local MSP_OSD_CONFIG = 84

local MSP_BUILD_INFO = 5

local BUILD_OPTION_GPS    = 16412
local BUILD_OPTION_VTX    = 16421
local BUILD_OPTION_OSD_SD = 16416

local isGpsRead = false
local isVtxRead = false
local isOsdSDRead = false

local lastRunTS = 0
local INTERVAL = 100
local isInFlight = false

local returnTable = {
    f = nil,
    t = "",
}

local function processBuildInfoReply(payload)
    local headLength = 26 -- DATE(11) + TIME(8) + REVISION(7)
    local optionsLength = #payload - headLength
    if (optionsLength <= 0) or ((optionsLength % 2) ~= 0) then
        return -- invalid payload
    end

    features.gps = false
    features.vtx = false
    features.osdSD = false
    for i = headLength + 1, #payload, 2 do
        local byte1 = bit32.lshift(payload[i], 0)
        local byte2 = bit32.lshift(payload[i + 1], 8)
        local word = bit32.bor(byte1, byte2)
        if word == BUILD_OPTION_GPS then
            features.gps = true
        elseif word == BUILD_OPTION_VTX then
            features.vtx = true
        elseif word == BUILD_OPTION_OSD_SD then
            features.osdSD = true
        end
    end
end

local function processMspReply(cmd, payload, err)
    isInFlight = false
    local isOkay = not err
    if cmd == MSP_BUILD_INFO then
        isGpsRead = true
        isVtxRead = true
        isOsdSDRead = true
        if isOkay then
            processBuildInfoReply(payload)
        end
    elseif cmd == MSP_GPS_CONFIG then
        isGpsRead = true
        local providerSet = payload[1] ~= 0
        features.gps = isOkay and providerSet
    elseif cmd == MSP_VTX_CONFIG then
        isVtxRead = true
        local vtxTableAvailable = payload[12] ~= 0
        features.vtx = isOkay and vtxTableAvailable
    elseif cmd == MSP_OSD_CONFIG then
        isOsdSDRead = true
        local osdSDAvailable = payload[1] ~= 0
        features.osdSD = isOkay and osdSDAvailable
    end
end

local function updateFeatures()
    if lastRunTS + INTERVAL < getTime() then
        lastRunTS = getTime()
        local cmd
        if apiVersion >= 1.46 then
            cmd = MSP_BUILD_INFO
            returnTable.t = "Checking options..."
        elseif not isGpsRead then
            cmd = MSP_GPS_CONFIG
            returnTable.t = "Checking GPS..."
        elseif not isVtxRead then
            cmd = MSP_VTX_CONFIG
            returnTable.t = "Checking VTX..."
        elseif not isOsdSDRead then
            cmd = MSP_OSD_CONFIG
            returnTable.t = "Checking OSD (SD)..."
        end
        if cmd and not isInFlight then
            protocol.mspRead(cmd)
            isInFlight = true
        end
    end
    mspProcessTxQ()
    processMspReply(mspPollReply())
    return isGpsRead and isVtxRead and isOsdSDRead
end

returnTable.f = updateFeatures

return returnTable
