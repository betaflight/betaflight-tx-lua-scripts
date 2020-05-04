local template = loadScript(radio.templateHome.."pwm.lua")
if template then
    template = template()
else
    template = assert(loadScript(radio.templateHome.."default_template.lua"))()
end
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
local yMinLim = radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local inc = { x = function(val) x = x + val return x end, y = function(val) y = y + val return y end }
local labels = {}
local fields = {}

local escProtocols = { [0] = "PWM", "OS125", "OS42", "MSHOT" }

if apiVersion >= 1.020 then
    escProtocols[#escProtocols + 1] = "BRSH"
end
if apiVersion >= 1.031 then
    escProtocols[#escProtocols + 1] = "DS150"
    escProtocols[#escProtocols + 1] = "DS300"
    escProtocols[#escProtocols + 1] = "DS600"
    if apiVersion < 1.042 then
        escProtocols[#escProtocols + 1] = "DS1200"
    end
    if apiVersion >= 1.036 then
        escProtocols[#escProtocols + 1] = "PS1000"
    end
end

if apiVersion >= 1.043 then
    escProtocols[#escProtocols + 1] = "DISABLED"
end

if apiVersion >= 1.031 and apiVersion <= 1.040 then
    fields[#fields + 1] = { t = "32kHz Sampling",  x = x,      y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 9 }, table = { [0] = "OFF", "ON" }, upd = function(self) self.updateRateTables(self) end }
end

if apiVersion >= 1.016 then
    if apiVersion <= 1.042 then
        fields[#fields + 1] = { t = "Gyro Update", x = x,      y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 32, vals = { 1 }, table = {}, upd = function(self) self.updatePidRateTable(self) end }
        fields[#fields + 1] = { t = "PID Loop",    x = x,      y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 16, vals = { 2 }, table = {} }
    end
    fields[#fields + 1] = { t = "Protocol",        x = x,      y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #escProtocols, vals = { 4 }, table = escProtocols }
    fields[#fields + 1] = { t = "Unsynced PWM",    x = x,      y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 3 }, table = { [0] = "OFF", "ON" } }
    fields[#fields + 1] = { t = "PWM Frequency",   x = x,      y = inc.y(lineSpacing), sp = x + sp, min = 200, max = 32000, vals = { 5, 6 }, }
end

if apiVersion >= 1.031 then
    fields[#fields + 1] = { t = "Idle Throttle %", x = x,      y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2000, vals = { 7, 8 }, scale = 100 }
end

return {
    read        = 90, -- MSP_ADVANCED_CONFIG
    write       = 91, -- MSP_SET_ADVANCED_CONFIG
    reboot      = true,
    eepromWrite = true,
    title       = "PWM",
    minBytes    = 6,
    labels      = labels,
    fields      = fields,
    gyroRates   = {},
    getGyroDenomFieldIndex = function(self)
        for i=1,#self.fields do
            if self.fields[i].vals[1] == 1 then
                return i
            end
        end
    end,
    getPidDenomFieldIndex = function(self)
        for i=1,#self.fields do
            if self.fields[i].vals[1] == 2 then
                return i
            end
        end
    end,
    calculateGyroRates = function(self, baseRate)
        local idx = self.getGyroDenomFieldIndex(self)
        for i=1, 32 do
            self.gyroRates[i] = baseRate/i
            self.fields[idx].table[i] = string.format("%.2f",baseRate/i)
        end
    end,
    calculatePidRates = function(self, baseRate)
        local idx = self.getPidDenomFieldIndex(self)
        for i=1, 16 do
            self.fields[idx].table[i] = string.format("%.2f",baseRate/i)
        end
    end,
    updateRateTables = function(self)
        if (self.values[9] or 0) == 0 then
            self.calculateGyroRates(self, 8)
            self.calculatePidRates(self, 8)
        elseif self.values[9] == 1 then
            self.calculateGyroRates(self, 32)
            self.calculatePidRates(self, 32)
        end
    end,
    updatePidRateTable = function(self)
        self.updateRateTables(self)
        local newRateIdx = self.values[1]
        local newRate = self.gyroRates[newRateIdx]
        self.calculatePidRates(self, newRate)
    end
}
