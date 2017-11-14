return {
    read              = 90, -- MSP_ADVANCED_CONFIG
    write             = 91, -- MSP_SET_ADVANCED_CONFIG
    reboot            = true,
    eepromWrite       = true,
    title             = "PWM",
    minBytes             = 9,
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
        { x = 130, y = 68,  vals = { 4 },    min = 0,   max = 9,  to = MIDSIZE,
          table = { [0] = "OFF", "ONESHOT125", "ONESHOT42",
                          "MULTISHOT","BRUSHED",
                          "DSHOT150", "DSHOT300", "DSHOT600","DSHOT1200",
                          "PROSHOT1000" }
        },
        { x = 130, y = 110,  vals = { 9 },    min = 0,   max = 1, to = MIDSIZE,
          table = { [0] = "OFF", "ON" },
          upd = function(self) self.updateRateTables(self) end
        },
        { x = 130, y = 155, vals = { 1 },    min = 1,   max = 32, to = MIDSIZE,
          upd = function(self) self.updatePidRateTable(self) end
        },
        { x = 130, y = 200, vals = { 2 },    min = 1,   max = 16, to = MIDSIZE },
        { x = 350, y = 110, vals = { 3 },    min = 0,   max =  1, to = MIDSIZE,
          table = { [0] = "OFF", "ON" } },
        { x = 350, y = 155, vals = { 5, 6 }, min = 200, max = 32000, to = MIDSIZE },
        { x = 350, y = 200, vals = { 7, 8 }, min = 0,   max = 2000, scale = 100, to = MIDSIZE },
    },
    calculateGyroRates = function(self, baseRate)
        self.gyroRates = {}
        self.fields[2].table = {}
        for i=1, 32 do
            self.gyroRates[i] = baseRate/i
            local fmt = nil
            self.fields[2].table[i] = string.format("%.2f",baseRate/i)
        end
    end,
    calculatePidRates = function(self, baseRate)
        self.fields[3].table = {}
        for i=1, 16 do
            self.fields[3].table[i] = string.format("%.2f",baseRate/i)
        end
    end,
    updateRateTables = function(self)
        if self.values[9] == 0 then
            self.calculateGyroRates(self, 8)
            self.calculatePidRates(self, 8)
        elseif self.values[9] == 1 then
            self.calculateGyroRates(self, 32)
            self.calculatePidRates(self, 32)
        end
    end,
    updatePidRateTable = function(self)
        local newRateIdx = self.values[1]
        local newRate = self.gyroRates[newRateIdx]
        self.calculatePidRates(self, newRate)
    end
}
