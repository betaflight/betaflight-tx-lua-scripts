local CONST = {
    frame = {
        destination = 1,
        source = 2,
        command = 3,
        content = 4
    },
    address = {
        transmitter = 0xEA,
        betaflight = 0xC8
    },
    frameType = {
        displayPort = 0x7D 
    },
    command = {
        update = 0x01,
        clear = 0x02,
        open = 0x03,
        close = 0x04,
        refresh = 0x05
    }
}

local function crsfDisplayPortCmd(cmd, data)
    local payloadOut = { CONST.address.betaflight, CONST.address.transmitter, cmd }
    if data ~= nil then
        for i = 1, #(data) do
            payloadOut[3 + i] = data[i]
        end
    end
    return crossfireTelemetryPush(CONST.frameType.displayPort, payloadOut) 
end

protocol.cms.poll = function()
    local command = nil
    local dataOut = {}
    local frameType, data = crossfireTelemetryPop()
    if (data ~= nil) and (#data > 2) then
        if (frameType == CONST.frameType.displayPort) and (data[CONST.frame.destination] == CONST.address.transmitter) and (data[CONST.frame.source] == CONST.address.betaflight) then
            for k,v in pairs(CONST.command) do
                if (v == data[CONST.frame.command]) then
                    command = k
                end
            end
            for i = CONST.frame.content, #data do
                dataOut[#dataOut + 1] = data[i]
            end
        end
    end
    return command, dataOut
end

protocol.cms.open = function(rows, cols) 
    return crsfDisplayPortCmd(CONST.command.open, { rows, cols })
end

protocol.cms.close = function()
    return crsfDisplayPortCmd(CONST.command.close, nil)
end

protocol.cms.refresh = function()
    return crsfDisplayPortCmd(CONST.command.refresh, nil)
end

