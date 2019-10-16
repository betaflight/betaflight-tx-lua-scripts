local display = assert(loadScript(radio.templateHome.."pwm.lua"))()
return {
    read              = 90, -- MSP_ADVANCED_CONFIG
    write             = 91, -- MSP_SET_ADVANCED_CONFIG
    reboot            = true,
    eepromWrite       = true,
    title             = "PWM",
    minBytes          = 9,
    yMinLimit         = display.yMinLimit,
    yMaxLimit         = display.yMaxLimit,
    text              = display.text,
    fields            = display.fields,
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
