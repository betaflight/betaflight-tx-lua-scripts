return {
    text= {
        { t = "32K", x = 10, y = 14,    },
        { t = "Gyro", x = 10, y = 24,   },
        { t = "PID", x = 10, y = 34,    },
        { t = "Prot", x = 58, y = 14,   },
        { t = "Unsync", x = 58, y = 24, },
        { t = "PWM", x = 58, y = 34,    },
        { t = "Idle", x = 58, y = 44,   }
    },
    fields = {
        { x = 32, y = 14, vals = { 9 }, min = 0, max = 1, table = { [0] = "OFF", "ON" }, upd = function(self) self.updateRateTables(self) end },
        { x = 32, y = 24, vals = { 1 }, min = 1, max = 32, upd = function(self) self.updatePidRateTable(self) end },
        { x = 32, y = 34, vals = { 2 }, min = 1, max = 16, },
        { x = 90, y = 14, vals = { 4 }, min = 0, max = 9, table = { [0] = "OFF", "OS125", "OS42", "MSHOT","BRSH", "DS150", "DS300", "DS600","DS1200", "PS1000" } },
        { x = 90, y = 24, vals = { 3 }, min = 0, max = 1, table = { [0] = "OFF", "ON" } },
        { x = 90, y = 34, vals = { 5, 6 }, min = 200, max = 32000, },
        { x = 90, y = 44, vals = { 7, 8 }, min = 0, max = 2000, scale = 100 },
    },
}
