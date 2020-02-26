local MSP_VTX_CONFIG = 88
local MSP_VTXTABLE_BAND = 137
local MSP_VTXTABLE_POWERLEVEL = 138

local vtxTableAvailable = false
local vtxConfigReceived = false
local vtxFrequencyTableReceived = false
local vtxPowerTableReceived = false
local vtxTablesReceived = false
local requestedBand = 1
local requestedPowerLevel = 1
local vtxTableConfig = {}
local frequencyTable = {}
local frequenciesPerBand = 0
local bandTable = {}
local powerTable = {}

local lastRunTS = 0
local INTERVAL = 100

local function processMspReply(cmd, payload)
    if cmd == MSP_VTX_CONFIG then
        vtxConfigReceived = true
        vtxTableAvailable = payload[12] ~= 0
        vtxTableConfig.bands = payload[13]
        vtxTableConfig.channels = payload[14]
        vtxTableConfig.powerLevels = payload[15]
    end
    if cmd == MSP_VTXTABLE_BAND and payload[1] == requestedBand then
        local i = 1
        local receivedBand = payload[i]
        i = i + 1
        local bandNameLength = payload[i]
        i = i + bandNameLength + 1
        bandTable[receivedBand] = string.char(payload[i])
        i = i + 2
        local channels = payload[i]
        i = i + 1
        frequencyTable[receivedBand] = {}
        for channel = 1, channels do
            local frequency = 0
            for idx=1, 2 do
                local raw_val = payload[i]
                raw_val = bit32.lshift(raw_val, (idx-1)*8)
                frequency = bit32.bor(frequency, raw_val)
                i = i + 1
            end
            frequencyTable[receivedBand][channel] = frequency
        end
        requestedBand = requestedBand + 1
        vtxFrequencyTableReceived = requestedBand > vtxTableConfig.bands
    end
    if cmd == MSP_VTXTABLE_POWERLEVEL and payload[1] == requestedPowerLevel then
        local i = 1
        local powerLevel = payload[i]
        i = i + 3
        local powerLabelLength = payload[i]
        i = i + 1
        powerTable[powerLevel] = ''
        for c = 1, powerLabelLength do
            powerTable[powerLevel] = powerTable[powerLevel]..string.char(payload[i])
            i = i + 1
        end
        requestedPowerLevel = requestedPowerLevel + 1
        vtxPowerTableReceived = requestedPowerLevel > vtxTableConfig.powerLevels
    end 
end

local function getVtxTables()
    if lastRunTS + INTERVAL < getTime() then
        lastRunTS = getTime()
        if not vtxConfigReceived then
            protocol.mspRead(MSP_VTX_CONFIG)
        elseif vtxConfigReceived and not vtxTableAvailable then
            return true
        elseif not vtxFrequencyTableReceived then
            protocol.mspWrite(MSP_VTXTABLE_BAND, { requestedBand })
        elseif not vtxPowerTableReceived then
            protocol.mspWrite(MSP_VTXTABLE_POWERLEVEL, { requestedPowerLevel })
        else
            vtxTablesReceived = true
        end
    end
    if vtxTablesReceived then
        local f = io.open("/BF/VTX/"..model.getInfo().name..".lua", 'w')
        io.write(f, "return {", "\n")
        io.write(f, "    frequencyTable = {", "\n")
        for i = 1, #frequencyTable do
            local frequencyString = "        { "
            for k = 1, #frequencyTable[i] do
                frequencyString = frequencyString..tostring(frequencyTable[i][k])..", "
            end
            frequencyString = frequencyString.."},"
            io.write(f, frequencyString, "\n")
        end
        io.write(f, "    },", "\n")
        io.write(f, "    frequenciesPerBand = "..tostring(vtxTableConfig.channels)..",", "\n")
        local bandString = "    bandTable = { [0]=\"U\", "
        for i = 1, #bandTable do
            bandString = bandString.."\""..bandTable[i].."\", "
        end
        bandString = bandString.."},"
        io.write(f, bandString, "\n")
        local powerString = "    powerTable = { "
        for i = 1, #powerTable do
            powerString = powerString.."\""..powerTable[i].."\", "
        end
        powerString = powerString.."},"
        io.write(f, powerString, "\n")
        io.write(f, "}", "\n")
        io.close(f)
        assert(loadScript("/BF/VTX/"..model.getInfo().name..".lua", 'c'))
    end
    mspProcessTxQ()
    processMspReply(mspPollReply())
    return vtxTablesReceived
end

return getVtxTables
