return {
    read              = 90, -- MSP_ADVANCED_CONFIG
    write             = 91, -- MSP_SET_ADVANCED_CONFIG
    reboot            = true,
    eepromWrite       = true,
    title             = "PWM",
    minBytes             = 9,
    text= {
        { t = "Protocol",    x = 50,  y = 65, to = SMLSIZE },
        { t = "32K",         x = 50,  y = 110, to = SMLSIZE },
        { t = "Gyro Rt",     x = 50,  y = 155, to = SMLSIZE },
        { t = "PID Rt",      x = 50,  y = 200, to = SMLSIZE },
        { t = "Unsynced",    x = 240, y = 110, to = SMLSIZE },
        { t = "PWM Rate",    x = 240, y = 155, to = SMLSIZE },
        { t = "Idle Offset", x = 240, y = 200, to = SMLSIZE }
    },
    fields = {
        { x = 130, y = 55,  vals = { 4 },    min = 0,   max = 9,     to = MIDSIZE, table = { [0] = "OFF", "ONESHOT125", "ONESHOT42", "MULTISHOT","BRUSHED", "DSHOT150", "DSHOT300", "DSHOT600","DSHOT1200", "PROSHOT1000" } },
        { x = 130, y = 95,  vals = { 9 },    min = 0,   max = 1,     to = DBLSIZE, table = { [0] = "OFF", "ON" }, upd = function(self) self.updateRateTables(self) end },
        { x = 130, y = 140, vals = { 1 },    min = 1,   max = 32,    to = DBLSIZE, upd = function(self) self.updatePidRateTable(self) end },
        { x = 130, y = 185, vals = { 2 },    min = 1,   max = 16,    to = DBLSIZE, },
        { x = 350, y = 95,  vals = { 3 },    min = 0,   max = 1,     to = DBLSIZE, table = { [0] = "OFF", "ON" } },
        { x = 350, y = 140, vals = { 5, 6 }, min = 200, max = 32000, to = DBLSIZE },
        { x = 350, y = 185, vals = { 7, 8 }, min = 0,   max = 2000,  to = DBLSIZE, scale = 100 },
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
