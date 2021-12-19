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

labels[#labels + 1] = { t = "Simplified PID",    x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "PID Tuning",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2, vals = { 1 }, table = { [0] = "OFF", "RP", "RPY" } }
fields[#fields + 1] = { t = "D Gains",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 5 }, scale = 100, mult = 5 }
fields[#fields + 1] = { t = "P&I Gains",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 6 }, scale = 100, mult = 5 }
fields[#fields + 1] = { t = "FF Gains",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 8 }, scale = 100, mult = 5 }
fields[#fields + 1] = { t = "D Max",             x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 7 }, scale = 100, mult = 5 }
fields[#fields + 1] = { t = "I Gains",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 4 }, scale = 100, mult = 5 }
fields[#fields + 1] = { t = "Pitch:Roll D",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 3 }, scale = 100, mult = 5 }
fields[#fields + 1] = { t = "Pitch:Roll P,I&FF", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 9 }, scale = 100, mult = 5 }
fields[#fields + 1] = { t = "Master Multiplier", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 2 }, scale = 100, mult = 5 }

labels[#labels + 1] = { t = "Simplified Filter", x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Gyro Tuning",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 36 }, table = { [0] = "OFF", "ON" } }
fields[#fields + 1] = { t = "Gyro Multiplier",   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 200, vals = { 37 }, scale = 100, mult = 5 }
fields[#fields + 1] = { t = "D Tuning",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 18 }, table = { [0] = "OFF", "ON" } }
fields[#fields + 1] = { t = "D Multiplier",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 200, vals = { 19 }, scale = 100, mult = 5 }

return {
    read        = 140, -- MSP_SIMPLIFIED_TUNING
    write       = 141, -- MSP_SET_SIMPLIFIED_TUNING
    title       = "Simplified Tuning",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 53,
    labels      = labels,
    fields      = fields,
}
