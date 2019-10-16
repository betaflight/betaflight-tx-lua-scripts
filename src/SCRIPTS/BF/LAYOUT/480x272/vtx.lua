return {
    text= {
        { t = "Band",    x = 36,  y = 110 },
        { t = "Channel", x = 36,  y = 155 },
        { t = "Power",   x = 232, y = 110 },
        { t = "Pit",     x = 232, y = 155 },
        { t = "Proto",   x = 36,  y =  68 },
        { t = "Freq",    x = 232, y =  68 },
    },
    fields = {
        { x = 130,  y = 110, min=0, max=5, vals = { 2 }, table = { [0]="U", "A", "B", "E", "F", "R" }, upd = function(self) self.handleBandChanUpdate(self) end },
        { x = 130,  y = 155, min=1, max=8, vals = { 3 }, upd =  function(self) self.handleBandChanUpdate(self) end },
        { x = 350,  y = 110, min=1, vals = { 4 }, upd = function(self) self.updatePowerTable(self) end },
        { x = 350,  y = 155, min=0, max=1, vals = { 5 }, table = { [0]="OFF", "ON" } },
        { x = 130,  y =  68, vals = { 1 }, write = false, ro = true, table = { [1]="RTC6705",[3]="SmartAudio",[4]="Tramp",[255]="None"} },
        { x = 350,  y = 68, min = 5000, max = 5999, vals = { 6 }, upd = function(self) self.handleFreqValUpdate(self) end },
    },
}