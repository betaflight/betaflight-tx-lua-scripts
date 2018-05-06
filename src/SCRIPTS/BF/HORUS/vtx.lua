
return {
    read           = 88, -- MSP_VTX_CONFIG
    write          = 89, -- MSP_VTX_SET_CONFIG
    eepromWrite    = true,
    reboot         = false,
    saveMaxRetries = 2,
    saveTimeout    = 300, -- 3s
    title          = "VTX",
    minBytes       = 5,
    text= {
        { t = "Band",    x = 36,  y = 110 },
        { t = "Channel", x = 36,  y = 155 },
        { t = "Power",   x = 232, y = 110 },
        { t = "Pit",     x = 232, y = 155 },
        { t = "Proto",   x = 36,  y =  68 },
        { t = "Freq",    x = 232, y =  68 },
    },
    fields = {
        -- Band
        { x = 130,  y = 110, min=1, max=5, vals = { 2 },  to = MIDSIZE,
          table = { "A", "B", "E", "F", "R" },
          upd = function(self) self.updateVTXFreq(self) end },
        -- Channel
        { x = 130,  y = 155, min=1, max=8, vals = { 3 },  to = MIDSIZE,
          upd =  function(self) self.updateVTXFreq(self) end },
        -- Power
        { x = 350,  y = 110, min=1, vals = { 4 },         to = MIDSIZE,
          upd = function(self) self.updatePowerTable(self) end },
        -- Pit mode
        { x = 350,  y = 155, min=0, max=1, vals = { 5 },  to = MIDSIZE,
          table = { [0]="OFF", "ON" } },
        -- Proto
        { x = 130,  y =  68, vals = { 1 },                to = MIDSIZE,
          write = false, ro = true,
          table = {[3]="SmartAudio",[4]="Tramp",[255]="None"} },
        -- Freq
        { x = 350,  y = 68, min=5000, max=6000, ro=true, to = MIDSIZE },
    },
    freqLookup = {
        { 5865, 5845, 5825, 5805, 5785, 5765, 5745, 5725 }, -- Boscam A
        { 5733, 5752, 5771, 5790, 5809, 5828, 5847, 5866 }, -- Boscam B
        { 5705, 5685, 5665, 5645, 5885, 5905, 5925, 5945 }, -- Boscam E
        { 5740, 5760, 5780, 5800, 5820, 5840, 5860, 5880 }, -- FatShark
        { 5658, 5695, 5732, 5769, 5806, 5843, 5880, 5917 }, -- RaceBand
    },
    postLoad = function (self)
        if self.values[2] == 0 or self.values[3] == 0 or self.values[4] == 0 then
            self.values = {}
        end
    end,
    preSave = function(self)
        local valsTemp = {}
        local channel = (self.values[2]-1)*8 + self.values[3]-1
        valsTemp[1] = bit32.band(channel,0xFF)
        valsTemp[2] = bit32.rshift(channel,8)
        valsTemp[3] = self.values[4]
        valsTemp[4] = self.values[5]
        return valsTemp
    end,
    updatePowerTable = function(self)
        if self.values and not self.fields[3].table then
            if self.values[1] == 3 then
                self.fields[3].table = { 25, 200, 500, 800 }
                self.fields[3].max = 4
            elseif self.values[1] == 4 then
                self.fields[3].table = { 25, 100, 200, 400, 600 }
                self.fields[3].max = 5
            end
        end
    end,
    updateVTXFreq = function(self)
        if (#(self.values) or 0) >= self.minBytes then
            if (self.fields[2].value or 0) > 0 and (self.fields[3].value or 0) > 0 then
                self.fields[6].value = self.freqLookup[self.values[2]][self.values[3]]
            end
        end
    end
}
