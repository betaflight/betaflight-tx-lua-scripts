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

if apiVersion >= 1.016 then
    labels[#labels + 1] = { t = "Stick",  x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Low",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1000, max = 2000, vals = { 6, 7 } }
    fields[#fields + 1] = { t = "Center", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1000, max = 2000, vals = { 4, 5 } }
    fields[#fields + 1] = { t = "High",   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1000, max = 2000, vals = { 2, 3 } }
end

if apiVersion >= 1.044 then
    labels[#labels + 1] = { t = "RC Smoothing",    x = x,            y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Mode",            x = x + indent,   y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 25 }, table = { [0] = "ON", "OFF" } }
    labels[#labels + 1] = { t = "Cutoffs",         x = x + indent,   y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Setpoint",        x = x + indent*2, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 255, vals = { 26 }, table = { [0] = "Auto" } }
    fields[#fields + 1] = { t = "Feedforward",     x = x + indent*2, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 255, vals = { 27 }, table = { [0] = "Auto" } }
    labels[#labels + 1] = { t = "Auto Smoothness", x = x + indent,   y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Setpoint",        x = x + indent*2, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 31 } }    
else
    if apiVersion >= 1.040 then
        labels[#labels + 1] = { t = "RC Smoothing",      x = x,          y = inc.y(lineSpacing) }
        fields[#fields + 1] = { t = "Type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 25 }, table = { [0] = "Interpolation", "Filter" } }
        fields[#fields + 1] = { t = "Channels",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4, vals = { 24 }, table = { [0] = "RP", "RPY", "RPYT", "T", "RT" } }
        labels[#labels + 1] = { t = "Input Filter",      x = x,          y = inc.y(lineSpacing) }
        fields[#fields + 1] = { t = "Cutoff",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 255, vals = { 26 }, table = { [0] = "Auto" } }
        fields[#fields + 1] = { t = "Type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 28 }, table = { [0] = "PT1", "BIQUAD"} }
        labels[#labels + 1] = { t = "Derivative Filter", x = x,          y = inc.y(lineSpacing) }
        fields[#fields + 1] = { t = "Cutoff",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 255, vals = { 27 }, table = { [0] = "Auto" } }
        fields[#fields + 1] = { t = "Type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 3, vals = { 29 }, table = { [0] = "Off", "PT1", "BIQUAD", "Auto"} }
    end

    if apiVersion >= 1.020 then
        fields[#fields + 1] = { t = "Interpolation", x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 3, vals = { 13 }, table={ [0]="Off", "Preset", "Auto", "Manual"} }
        fields[#fields + 1] = { t = "Interval",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 50, vals = { 14 } }
    end

    if apiVersion >= 1.042 then
        fields[#fields + 1] = { t = "Auto Smoothness", x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 50, vals = { 31 } }
    end
end

if apiVersion >= 1.031 then
    fields[#fields + 1] = { t = "Cam Angle", x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 90, vals = { 23 } }
end

return {
    read        = 44, -- MSP_RX_CONFIG
    write       = 45, -- MSP_SET_RX_CONFIG
    title       = "RX",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 12,
    labels      = labels,
    fields      = fields,
}
