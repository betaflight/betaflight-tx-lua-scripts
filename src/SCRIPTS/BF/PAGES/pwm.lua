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
    fieldLayout       = display.fieldLayout,
    fields            = {
        { vals = { 9 }, min = 0, max = 1, table = { [0] = "OFF", "ON" }, upd = function(self) self.updateRateTables(self) end },
        { vals = { 1 }, min = 1, max = 32, upd = function(self) self.updatePidRateTable(self) end },
        { vals = { 2 }, min = 1, max = 16, },
        { vals = { 4 }, min = 0, max = 9, table = { [0] = "OFF", "OS125", "OS42", "MSHOT","BRSH", "DS150", "DS300", "DS600","DS1200", "PS1000" } },
        { vals = { 3 }, min = 0, max = 1, table = { [0] = "OFF", "ON" } },
        { vals = { 5, 6 }, min = 200, max = 32000, },
        { vals = { 7, 8 }, min = 0, max = 2000, scale = 100 },
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
