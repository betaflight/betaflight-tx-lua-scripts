return {
    text= {
        { t = "Protocol",    x = 36,  y = 68  },
        { t = "32K",         x = 36,  y = 110 },
        { t = "Gyro Rt",     x = 36,  y = 155 },
        { t = "PID Rt",      x = 36,  y = 200 },
        { t = "Unsynced",    x = 232, y = 110 },
        { t = "PWM Rate",    x = 232, y = 155 },
        { t = "Idle Offset", x = 232, y = 200 }
    },
    fields = {
        { x = 130, y = 68,  vals = { 4 },    min = 0,   max = 9, table = { [0] = "OFF", "ONESHOT125", "ONESHOT42", "MULTISHOT", "BRUSHED", "DSHOT150", "DSHOT300", 
                "DSHOT600", "DSHOT1200", "PROSHOT1000" }
        },
        { x = 130, y = 110,  vals = { 9 },    min = 0,   max = 1, table = { [0] = "OFF", "ON" }, upd = function(self) self.updateRateTables(self) end },
        { x = 130, y = 155, vals = { 1 },    min = 1,   max = 32, upd = function(self) self.updatePidRateTable(self) end },
        { x = 130, y = 200, vals = { 2 },    min = 1,   max = 16, },
        { x = 350, y = 110, vals = { 3 },    min = 0,   max =  1, table = { [0] = "OFF", "ON" } },
        { x = 350, y = 155, vals = { 5, 6 }, min = 200, max = 32000, },
        { x = 350, y = 200, vals = { 7, 8 }, min = 0,   max = 2000, scale = 100, },
    },
}
