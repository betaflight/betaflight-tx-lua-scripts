local template = loadScript(radio.templateHome.."simplified_pids.lua")
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

labels[#labels + 1] = { t = "Simplified Pid",    x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Pid Tuning",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2, vals = { 1 }, table = { [0] = "OFF", "RP", "RPY" } }
fields[#fields + 1] = { t = "Master Mult",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 50, max = 200, vals = { 2 }, scale = 100, mult = 5 }
fields[#fields + 1] = { t = "R/P Ratio",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 50, max = 200, vals = { 3 }, scale = 100, mult = 5 }
fields[#fields + 1] = { t = "I Gain",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 50, max = 200, vals = { 4 }, scale = 100, mult = 5 }
fields[#fields + 1] = { t = "P/D Ratio",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 50, max = 200, vals = { 5 }, scale = 100, mult = 5 }
fields[#fields + 1] = { t = "PD Gain",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 50, max = 200, vals = { 6 }, scale = 100, mult = 5 }
fields[#fields + 1] = { t = "Dmin Ratio",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 50, max = 200, vals = { 7 }, scale = 100, mult = 5 }
fields[#fields + 1] = { t = "FF Gain",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 50, max = 200, vals = { 8 }, scale = 100, mult = 5 }

labels[#labels + 1] = { t = "Simplified Filter", x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Gyro Tuning",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 9 }, table = { [0] = "OFF", "ON" } }
fields[#fields + 1] = { t = "Gyro Mult",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 50, max = 200, vals = { 10 }, scale = 100, mult = 5 }
fields[#fields + 1] = { t = "D Tuning",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 11 }, table = { [0] = "OFF", "ON" } }
fields[#fields + 1] = { t = "D Mult",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 50, max = 200, vals = { 12 }, scale = 100, mult = 5 }

return {
   read        = 140, -- MSP_SIMPLIFIED_TUNING
   write       = 141, -- MSP_SET_SIMPLIFIED_TUNING
   title       = "Simplified Tuning",
   reboot      = false,
   eepromWrite = true,
   minBytes    = 12,
   labels      = labels,
   fields      = fields,
}
