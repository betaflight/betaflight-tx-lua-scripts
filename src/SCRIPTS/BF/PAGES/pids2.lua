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

local dMinMax = 100

if apiVersion >= 1.44 then
    dMinMax = 250
end

if apiVersion >= 1.40 then
    x = margin
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = "",          x = x, y = inc.y(tableSpacing.header) }
    labels[#labels + 1] = { t = "ROLL",      x = x, y = inc.y(tableSpacing.row) }
    labels[#labels + 1] = { t = "PITCH",     x = x, y = inc.y(tableSpacing.row) }
    labels[#labels + 1] = { t = "YAW",       x = x, y = inc.y(tableSpacing.row) }

    x = x + tableSpacing.col
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = "FF",        x = x, y = inc.y(tableSpacing.header) }
    fields[#fields + 1] = {                  x = x, y = inc.y(tableSpacing.row), min = 0, max = 2000, vals = { 33, 34 } }
    fields[#fields + 1] = {                  x = x, y = inc.y(tableSpacing.row), min = 0, max = 2000, vals = { 35, 36 } }
    fields[#fields + 1] = {                  x = x, y = inc.y(tableSpacing.row), min = 0, max = 2000, vals = { 37, 38 } }

    if apiVersion >= 1.41 then
        x = x + tableSpacing.col
        y = yMinLim - tableSpacing.header

        labels[#labels + 1] = { t = "D Min", x = x, y = inc.y(tableSpacing.header) }
        fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = dMinMax, vals = { 40 } }
        fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = dMinMax, vals = { 41 } }
        fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = dMinMax, vals = { 42 } }
    end
    
    x = margin
    y = inc.y(lineSpacing*0.4)
end

if apiVersion >= 1.40 then
    labels[#labels + 1] = { t = "Feedforward",          x = x,          y = inc.y(lineSpacing) }
    if apiVersion >= 1.44 then
        fields[#fields + 1] = { t = "Jitter Reduction", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 20, vals = { 55 } }
        fields[#fields + 1] = { t = "Smoothness",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 75, vals = { 52 } }
        fields[#fields + 1] = { t = "Averaging",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 3, vals = { 51 }, table = { [0] = "OFF", "2_POINT", "3_POINT", "4_POINT" } }
        fields[#fields + 1] = { t = "Boost",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 50, vals = { 53 } }
        fields[#fields + 1] = { t = "Max Rate Limit",   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 150, vals = { 54 } }
    end
    fields[#fields + 1] = { t = "Transition",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100, vals = { 9 }, scale = 100 }
end

if apiVersion >= 1.41 then
    labels[#labels + 1] = { t = "D Min",       x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Gain",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100, vals = { 43 } }
    fields[#fields + 1] = { t = "Advance",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 44 } }
end

if apiVersion >= 1.21 and apiVersion <= 1.39 then
    labels[#labels + 1] = { t = "Dterm Setpoint", x = x, y = inc.y(lineSpacing) }
    if apiVersion >= 1.21 and apiVersion <= 1.38 then
        fields[#fields + 1] = { t = "Weight",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 254, vals = { 10 }, scale = 100 }
    else
        fields[#fields + 1] = { t = "Weight",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 254, vals = { 25 }, scale = 100 }
    end
    fields[#fields + 1] = { t = "Transition",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100, vals = { 9 },  scale = 100 }
end

return {
    read        = 94, -- MSP_PID_ADVANCED
    write       = 95, -- MSP_SET_PID_ADVANCED
    title       = "PIDs (2/2)",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 17,
    labels      = labels,
    fields      = fields,
}
