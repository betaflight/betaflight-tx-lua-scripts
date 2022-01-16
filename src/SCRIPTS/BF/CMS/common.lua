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
    redraws = 2,
    reset = function()
        screen.data = {}
        screen.batchId = 0
        screen.sequence = 0
    end,
    draw = function()
        lcd.clear()
        lcd.drawText(screen.config.refresh.left, screen.config.refresh.top, screen.config.refresh.text, screen.config.textSize)
        for char = 1, #screen.buffer do
            if (screen.buffer[char] ~= 32) then -- skip spaces to avoid CPU spikes
                local c = string.char(screen.buffer[char])
                local row = math.ceil(char / screen.config.cols)
                local col = char - ((row - 1) * screen.config.cols)
                local xPos = ((col - 1) * screen.config.pixelsPerChar) + screen.config.xIndent + 1
                local yPos = ((row - 1) * screen.config.pixelsPerRow) + screen.config.yOffset + 1
                lcd.drawText(xPos, yPos, c, screen.config.textSize)
            end
        end
    end,
}

cms = {
    menuOpen = false,
    synced = false,
    init = function(cmsConfig) 
        screen.config = assert(cmsConfig, "Resolution not supported")
        screen.reset()
        protocol.cms.close()
        cms.menuOpen = false
        cms.synced = false
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
            local firstChunk = bit32.btest(data[CONST.offset.meta], CONST.bitmask.firstChunk)
            local lastChunk = bit32.btest(data[CONST.offset.meta], CONST.bitmask.lastChunk)
            local batchId = bit32.band(data[CONST.offset.meta], CONST.bitmask.batchId)
            local sequence = data[CONST.offset.sequence]
            if firstChunk then
                screen.reset()
                screen.batchId = batchId
                screen.sequence = 0
            end
            if (screen.batchId == batchId) and (screen.sequence == sequence) then
                screen.sequence = sequence + 1
                for i = CONST.offset.data, #data do
                    screen.data[#screen.data + 1] = data[i]
                end
                if lastChunk then
                    screen.buffer = cRleDecode(screen.data)
                    screen.redraws = 2
                    screen.reset()
                    cms.synced = true
                end
            else
                protocol.cms.refresh()
            end
            cms.menuOpen = true
        elseif (command == "clear") then
            screen.reset()
        end
        if screen.redraws > 0 then
            screen.draw()
            screen.redraws = screen.redraws - 1
        end
    end    
}
