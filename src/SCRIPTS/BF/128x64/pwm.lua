return {
    text= {
        { t = "32K", x = 10, y = 14, to = SMLSIZE },
        { t = "Gyro", x = 10, y = 24, to = SMLSIZE },
        { t = "PID", x = 10, y = 34, to = SMLSIZE },
        { t = "Prot", x = 58, y = 14, to = SMLSIZE },
        { t = "Unsync", x = 58, y = 24, to = SMLSIZE },
        { t = "PWM", x = 58, y = 34, to = SMLSIZE },
        { t = "Idle", x = 58, y = 44, to = SMLSIZE }
    },
    fields = {
        { x = 32, y = 14, vals = { 9 }, min = 0, max = 1, to = SMLSIZE, table = { [0] = "OFF", "ON" }, upd = function(self) self.updateRateTables(self) end },
        { x = 32, y = 24, vals = { 1 }, min = 1, max = 32, to = SMLSIZE, upd = function(self) self.updatePidRateTable(self) end },
        { x = 32, y = 34, vals = { 2 }, min = 1, max = 16, to = SMLSIZE, },
        { x = 90, y = 14, vals = { 4 }, min = 0, max = 9, to = SMLSIZE, table = { [0] = "OFF", "OS125", "OS42", "MSHOT","BRSH", "DS150", "DS300", "DS600","DS1200", "PS1000" } },
        { x = 90, y = 24, vals = { 3 }, min = 0, max = 1, to = SMLSIZE, table = { [0] = "OFF", "ON" } },
        { x = 90, y = 34, vals = { 5, 6 }, min = 200, max = 32000, to = SMLSIZE },
        { x = 90, y = 44, vals = { 7, 8 }, min = 0, max = 2000, to = SMLSIZE, scale = 100 },
    },
}
