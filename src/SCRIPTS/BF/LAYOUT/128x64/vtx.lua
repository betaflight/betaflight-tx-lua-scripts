return {
    text = {},
    fields = {
        { t = "Band",    x = 10,  y = 14, sp = 30, min=0, max=5, vals = { 2 }, table = { [0]="U", "A", "B", "E", "F", "R" }, upd = function(self) self.handleBandChanUpdate(self) end },
        { t = "Chan",    x = 10,  y = 24, sp = 30, min=1, max=8, vals = { 3 }, upd = function(self) self.handleBandChanUpdate(self) end },
        { t = "Power",   x = 10,  y = 34, sp = 30, min=1, vals = { 4 }, upd = function(self) self.updatePowerTable(self) end },
        { t = "Pit",     x = 10,  y = 44, sp = 30, min=0, max=1, vals = { 5 }, table = { [0]="OFF", "ON" } },
        { t = "Dev",     x = 70,  y = 14, sp = 25, write = false, ro = true, vals = { 1 }, table = { [1]="6705",[3]="SA",[4]="Tramp",[255]="None"} },
        { t = "Freq",    x = 70,  y = 24, sp = 25, min = 5000, max = 5999, vals = { 6 }, upd = function(self) self.handleFreqValUpdate(self) end },
    },
}