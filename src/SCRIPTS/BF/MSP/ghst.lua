-- GHST Frame Types
local GHST_FRAMETYPE_MSP_REQ    = 0x21
local GHST_FRAMETYPE_MSP_WRITE  = 0x22
local GHST_FRAMETYPE_MSP_RESP   = 0x28

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
