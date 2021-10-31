local MSP_BOARD_INFO = 4

local boardInfoReceived = false

local boardIdentifier = ""
local hardwareRevision = 0
local boardType = 0
local targetCapabilities = 0
local targetName = ""
local boardName = ""
local manufacturerId = ""
local signature = {}
local mcuTypeId = 255
local configurationState = 0
local gyroSampleRateHz = 0
local configurationProblems = 0
local spiRegisteredDeviceCount = 0
local i2cRegisteredDeviceCount = 0

local lastRunTS = 0
local INTERVAL = 100

local function processMspReply(cmd, payload)
    if cmd == MSP_BOARD_INFO then
        local length
        local i = 1
        length = 4
        for c = 1, 4 do
            boardIdentifier = boardIdentifier..string.char(payload[i])
            i = i + 1
        end
        for idx = 1, 2 do
            local raw_val = bit32.lshift(payload[i], (idx-1)*8)
            hardwareRevision = bit32.bor(hardwareRevision, raw_val)
            i = i + 1
        end
        if apiVersion >= 1.035 then
            boardType = payload[i]
        end
        i = i + 1
        if apiVersion >= 1.037 then
            targetCapabilities = payload[i]
            i = i + 1
            length = payload[i]
            i = i + 1
            for c = 1, length do
                targetName = targetName..string.char(payload[i])
                i = i + 1
            end
        end
        if apiVersion >= 1.039 then
            length = payload[i]
            i = i + 1
            for c = 1, length do
                boardName = boardName..string.char(payload[i])
                i = i + 1
            end
            length = payload[i]
            i = i + 1
            for c = 1, length do
                manufacturerId = manufacturerId..string.char(payload[i])
                i = i + 1
            end
            length = 32
            for c = 1, 32 do
                signature[#signature + 1] = payload[i]
                i = i + 1
            end
        end
        i = i + 1
        if apiVersion >= 1.041 then
            mcuTypeId = payload[i]
        end
        i = i + 1
        if apiVersion >= 1.042 then
            configurationState = payload[i]
        end
        if apiVersion >= 1.043 then
            for idx = 1, 2 do
                local raw_val = bit32.lshift(payload[i], (idx-1)*8)
                gyroSampleRateHz = bit32.bor(gyroSampleRateHz, raw_val)
                i = i + 1
            end
            for idx = 1, 4 do
                local raw_val = bit32.lshift(payload[i], (idx-1)*8)
                configurationProblems = bit32.bor(configurationProblems, raw_val)
                i = i + 1
            end
        end
        if apiVersion >= 1.044 then
            spiRegisteredDeviceCount = payload[i]
            i = i + 1
            i2cRegisteredDeviceCount = payload[i]
        end
        boardInfoReceived = true
    end
end

local function getBoardInfo()
    if lastRunTS + INTERVAL < getTime() then
        lastRunTS = getTime()
        if not boardInfoReceived then
            protocol.mspRead(MSP_BOARD_INFO)
        end
    end
    mspProcessTxQ()
    processMspReply(mspPollReply())
    if boardInfoReceived then
        local f = io.open("BOARD_INFO/"..mcuId..".lua", 'w')
        io.write(f, "return {", "\n")
        io.write(f, "    boardIdentifier = "..boardIdentifier..",", "\n")
        io.write(f, "    hardwareRevision = "..tostring(hardwareRevision)..",", "\n")
        io.write(f, "    boardType = "..tostring(boardType)..",", "\n")
        io.write(f, "    targetCapabilities = "..tostring(targetCapabilities)..",", "\n")
        io.write(f, "    targetName = "..targetName..",", "\n")
        io.write(f, "    boardName = "..boardName..",", "\n")
        io.write(f, "    manufacturerId = "..manufacturerId..",", "\n")
        local signatureString = "    signature = { "
        for i = 1, #signature do
            signatureString = signatureString..tostring(signature[i])..", "
        end
        signatureString = signatureString.."},"
        io.write(f, signatureString, "\n")
        io.write(f, "    mcuTypeId = "..tostring(mcuTypeId)..",", "\n")
        io.write(f, "    configurationState = "..tostring(configurationState)..",", "\n")
        io.write(f, "    gyroSampleRateHz = "..tostring(gyroSampleRateHz)..",", "\n")
        io.write(f, "    configurationProblems = "..tostring(configurationProblems)..",", "\n")
        io.write(f, "    spiRegisteredDeviceCount = "..tostring(spiRegisteredDeviceCount)..",", "\n")
        io.write(f, "    i2cRegisteredDeviceCount = "..tostring(i2cRegisteredDeviceCount)..",", "\n")
        io.write(f, "}", "\n")
        io.close(f)
        assert(loadScript("BOARD_INFO/"..mcuId..".lua", 'c'))
    end
    return boardInfoReceived
end

return { f = getBoardInfo, t = "Downloading board info" }
