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

labels[#labels + 1] = { t = "Voltage Settings",     x = x, y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Minimum Cell",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 500, vals = { 8, 9 }, scale = 100 }
fields[#fields + 1] = { t = "Maximum Cell",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 500, vals = { 10, 11 }, scale = 100 }
fields[#fields + 1] = { t = "Warning Cell",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 500, vals = { 12, 13 }, scale = 100 }

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
   fields      = fields
}
