-- GHST Frame Types
local GHST_FRAMETYPE_MSP_REQ    = 0x21
local GHST_FRAMETYPE_MSP_WRITE  = 0x22
local GHST_FRAMETYPE_MSP_RESP   = 0x28
local GHST_FRAMETYPE_DISPLAYPORT = 0x29

local ghstMspType = 0

protocol.mspSend = function(payload)
    return protocol.push(ghstMspType, payload)
end

protocol.mspRead = function(cmd)
    ghstMspType = GHST_FRAMETYPE_MSP_REQ
    return mspSendRequest(cmd, {})
end

protocol.mspWrite = function(cmd, payload)
    ghstMspType = GHST_FRAMETYPE_MSP_WRITE
    return mspSendRequest(cmd, payload)
end

protocol.mspPoll = function()
    while true do
        local type, data = ghostTelemetryPop()
        if type == GHST_FRAMETYPE_MSP_RESP then
            return data
        elseif type == nil then
            return nil
        end
    end
end

local function ghstDisplayPortCmd(cmd, data)
    local payloadOut = { cmd }
    if data ~= nil then
        for i = 1, #(data) do
            payloadOut[1 + i] = data[i]
        end
    end
    return ghostTelemetryPush(GHST_FRAMETYPE_DISPLAYPORT, payloadOut)
end
