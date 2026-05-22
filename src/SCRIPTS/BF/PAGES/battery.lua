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

-- Preset voltage values (in volts, matching scale = 100)
local batteryPresets = {
    [0] = { min = nil,  max = nil,   warn = nil  }, -- Custom (no preset applied)
    [1] = { min = 3.30, max = 4.20,  warn = 3.50 }, -- LiPo
    [2] = { min = 2.80, max = 4.20,  warn = 3.00 }, -- LiIon
    [3] = { min = 3.30, max = 4.35,  warn = 3.50 }, -- LiHV
}

labels[#labels + 1] = { t = "Voltage Settings",     x = x, y = inc.y(lineSpacing) }

-- vals={14} is a scratch byte appended in postLoad so the framework's edit-mode gate
-- (which requires f.vals) allows this field to be interacted with.
-- Byte 14 is not part of the 13-byte MSP_BATTERY_CONFIG payload; preSave strips it.
local battTypeField = { t = "Battery Type", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 3, value = 0,
    vals = { 14 },
    table = { [0] = "Custom", "LiPo", "LiIon", "LiHV" },
    postEdit = function(self) self.applyBatteryPreset(self) end }
fields[#fields + 1] = battTypeField

local minCellField  = { t = "Minimum Cell",  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 500, vals = { 8,  9  }, scale = 100 }
local maxCellField  = { t = "Maximum Cell",  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 500, vals = { 10, 11 }, scale = 100 }
local warnCellField = { t = "Warning Cell",  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 500, vals = { 12, 13 }, scale = 100 }
fields[#fields + 1] = minCellField
fields[#fields + 1] = maxCellField
fields[#fields + 1] = warnCellField

labels[#labels + 1] = { t = "Capacity Settings",    x = x, y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Battery Capacity",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, mult = 25, max = 20000, vals = { 4, 5 } }

return {
   read        = 32, -- MSP_BATTERY_CONFIG
   write       = 33, -- MSP_SET_BATTERY_CONFIG
   title       = "Battery",
   reboot      = true,
   eepromWrite = true,
   minBytes    = 13,
   labels      = labels,
   fields      = fields,
   postLoad = function(self)
       -- Auto-detect which preset matches the values loaded from the FC
       battTypeField.value = 0 -- default: Custom
       for i = 1, 3 do
           local p = batteryPresets[i]
           if minCellField.value == p.min and maxCellField.value == p.max and warnCellField.value == p.warn then
               battTypeField.value = i
               break
           end
       end
       -- Append scratch byte so Page.values[14] is non-nil (required by ui.lua edit gate)
       self.values[14] = battTypeField.value
   end,
   preSave = function(self)
       -- Strip the scratch byte; FC expects exactly 13 bytes for MSP_SET_BATTERY_CONFIG
       local payload = {}
       for i = 1, 13 do payload[i] = self.values[i] end
       return payload
   end,
   applyBatteryPreset = function(self)
       local preset = batteryPresets[battTypeField.value]
       if preset.min == nil then return end -- Custom: leave current values unchanged
       local function applyField(f, v)
           f.value = v
           local scaled = math.floor(v * (f.scale or 1) + 0.5)
           for idx = 1, #f.vals do
               self.values[f.vals[idx]] = bit32.rshift(scaled, (idx - 1) * 8)
           end
       end
       applyField(minCellField,  preset.min)
       applyField(maxCellField,  preset.max)
       applyField(warnCellField, preset.warn)
   end,
}
