local template = assert(loadScript(radio.template))()
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

local gyroSampleRateKhz

if apiVersion >= 1.44 then
    gyroSampleRateKhz = assert(loadScript("BOARD_INFO/"..mcuId..".lua"))().gyroSampleRateHz / 1000
end 

local escProtocols = { [0] = "PWM", "OS125", "OS42", "MSHOT" }

if apiVersion >= 1.20 then
    escProtocols[#escProtocols + 1] = "BRSH"
end
if apiVersion >= 1.31 then
    escProtocols[#escProtocols + 1] = "DS150"
    escProtocols[#escProtocols + 1] = "DS300"
    escProtocols[#escProtocols + 1] = "DS600"
    if apiVersion < 1.42 then
        escProtocols[#escProtocols + 1] = "DS1200"
    end
    if apiVersion >= 1.36 then
        escProtocols[#escProtocols + 1] = "PS1000"
    end
end

if apiVersion >= 1.43 then
    escProtocols[#escProtocols + 1] = "DISABLED"
end

labels[#labels + 1] = { t = "System Config", x = x, y = inc.y(lineSpacing) }
if apiVersion >= 1.31 and apiVersion <= 1.40 then
    fields[#fields + 1] = { t = "32kHz Sampling", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 9 }, table = { [0] = "OFF", "ON" }, upd = function(self) self.updateRateTables(self) end }
end
if apiVersion >= 1.44 then
    fields[#fields + 1] = { t = "Gyro Update", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 32, vals = { 1 }, table = {}, upd = function(self) self.updatePidRateTable(self) end, mult = -1, ro = true }
elseif apiVersion <= 1.42 then
    fields[#fields + 1] = { t = "Gyro Update", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 32, vals = { 1 }, table = {}, upd = function(self) self.updatePidRateTable(self) end, mult = -1 }
end
if apiVersion <= 1.42 or apiVersion >= 1.44 then
    fields[#fields + 1] = { t = "PID Loop",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 16, vals = { 2 }, table = {}, mult = -1 }
end

labels[#labels + 1] = { t = "ESC/Motor",       x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Protocol",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #escProtocols, vals = { 4 }, table = escProtocols }
if apiVersion >= 1.31 then
    fields[#fields + 1] = { t = "Idle Throttle %", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2000, vals = { 7, 8 }, scale = 100 }
end
fields[#fields + 1] = { t = "Unsynced PWM", x = x + indent,   y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 3 }, table = { [0] = "OFF", "ON" } }
fields[#fields + 1] = { t = "Frequency",    x = x + indent*2, y = inc.y(lineSpacing), sp = x + sp, min = 200, max = 32000, vals = { 5, 6 }, }

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
        baseRate = gyroSampleRateKhz or baseRate
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
