local CONST = {
    bitmask = {
        firstChunk = 0x80,
        lastChunk = 0x40,
        batchId = 0x3F,
        rleCharValueMask = 0x7F,
        rleCharRepeatedMask = 0x80
    },
    offset = {
        meta = 1,
        sequence = 2,
        data = 3
    }
}

local function cRleDecode(buf)
    local dest = {}
    local rpt = false
    local c = nil
    for i = 1, #buf do
        if (rpt == false) then
            c = bit32.band(buf[i], CONST.bitmask.rleCharValueMask)
            if (bit32.band(buf[i], CONST.bitmask.rleCharRepeatedMask) > 0) then
                rpt = true
            else
                dest[#dest + 1] = c
            end
        else
            for j = 1, buf[i] do
                dest[#dest + 1] = c
            end
            rpt = false
        end
    end
    return dest
end

screen = {
    config = nil,
    buffer = {},
    data = {},
    batchId = 0,
    sequence = 0,
    reset = function()
        screen.buffer = {}
        screen.data = {}
        screen.batchId = 0
        screen.sequence = 0
    end,
    draw = function()
        if (screen.buffer ~= nil and screen.config ~= nil and #screen.buffer > 0) then
            lcd.clear()
            for char = 1, #screen.buffer do
                if (screen.buffer[char] ~= 32) then -- skip spaces to avoid CPU spikes
                    c = string.char(screen.buffer[char])
                    row = math.ceil(char / screen.config.cols)
                    col = char - ((row - 1) * screen.config.cols)
                    xPos = ((col - 1) * screen.config.pixelsPerChar) + screen.config.xIndent + 1
                    yPos = ((row - 1) * screen.config.pixelsPerRow) + screen.config.yOffset + 1
                    lcd.drawText(xPos, yPos, c, screen.config.textSize)
                end
            end
            lcd.drawText(screen.config.refresh.left, screen.config.refresh.top, screen.config.refresh.text, screen.config.textSize)
        end
    end
}

cms = {
    menuOpen = false,
    init = function(cmsConfig) 
        screen.config = assert(cmsConfig, "Resolution not supported")
        screen.reset()
        protocol.cms.close()
        cms.menuOpen = false
    end,
    open = function()
        protocol.cms.open(screen.config.rows, screen.config.cols)
    end,
    refresh = function()
        protocol.cms.refresh()
    end,
    close = function()
        protocol.cms.close()
        cms.menuOpen = false
    end,
    update = function()
        local command, data = protocol.cms.poll()
        if (command == "update") then
            local firstChunk = bit32.band(data[CONST.offset.meta], CONST.bitmask.firstChunk)
            local lastChunk = bit32.band(data[CONST.offset.meta], CONST.bitmask.lastChunk)
            local batchId = bit32.band(data[CONST.offset.meta], CONST.bitmask.batchId)
            local sequence  = data[CONST.offset.sequence]
            local frameData = {}
            for i = CONST.offset.data, #data do
                frameData[#frameData + 1] = data[i]
            end
            if (firstChunk ~= 0) then
                screen.reset()
                screen.batchId = batchId
                screen.sequence = 0
            end
            if (screen.batchId == batchId) and (screen.sequence == sequence) then
                screen.sequence = sequence + 1
                for i = 1, #frameData do
                    screen.data[#screen.data + 1] = frameData[i]
                end
                if (lastChunk ~= 0) then
                    screen.buffer = cRleDecode(screen.data)
                    screen.draw()
                    screen.reset()
                end
            else
                protocol.cms.refresh()
            end
            cms.menuOpen = true
        elseif (command == "clear") then
            screen.reset()
        end
    end    
}
