return {
    text = {},
    fields = {
        { t = "Band",    x = 25,  y = 14, sp = 50, min=0, max=5, vals = { 2 }, to = SMLSIZE, table = { [0]="U", "A", "B", "E", "F", "R" }, upd = function(self) self.handleBandChanUpdate(self) end },
        { t = "Channel", x = 25,  y = 24, sp = 50, min=1, max=8, vals = { 3 }, to = SMLSIZE, upd = function(self) self.handleBandChanUpdate(self) end },
        { t = "Power",   x = 25,  y = 34, sp = 50, min=1, vals = { 4 }, to = SMLSIZE, upd = function(self) self.updatePowerTable(self) end },
        { t = "Pit",     x = 25,  y = 44, sp = 50, min=0, max=1, vals = { 5 }, to = SMLSIZE, table = { [0]="OFF", "ON" } },
        { t = "Dev",     x = 100, y = 14, sp = 32, write = false, ro = true, vals = { 1 }, to = SMLSIZE, table = { [1]="RTC6705",[3]="SmartAudio",[4]="Tramp",[255]="None"} },
        { t = "Freq",    x = 100, y = 24, sp = 32, min = 5000, max = 5999, vals = { 6 }, to = SMLSIZE, upd = function(self) self.handleFreqValUpdate(self) end },
    },
}
