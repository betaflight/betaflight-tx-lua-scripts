local template = loadScript(radio.templateHome.."rates.lua")
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

if apiVersion >= 1.016 then
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = "",      x = x, y = inc.y(tableSpacing.header) }
    labels[#labels + 1] = { t = "",      x = x, y = inc.y(tableSpacing.header) }
    labels[#labels + 1] = { t = "ROLL",  x = x, y = inc.y(tableSpacing.row) }
    labels[#labels + 1] = { t = "PITCH", x = x, y = inc.y(tableSpacing.row) }
    labels[#labels + 1] = { t = "YAW",   x = x, y = inc.y(tableSpacing.row) }

    x = x + tableSpacing.col
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = "RC",    x = x, y = inc.y(tableSpacing.header) }
    labels[#labels + 1] = { t = "Rate",  x = x, y = inc.y(tableSpacing.header) }
    if apiVersion >= 1.037 then
        fields[#fields + 1] = {          x = x, y = inc.y(tableSpacing.row), min = 0, max = 255, vals = { 1 }, scale = 100 }
        fields[#fields + 1] = {          x = x, y = inc.y(tableSpacing.row), min = 0, max = 255, vals = { 13 }, scale = 100 }
    else
        fields[#fields + 1] = {          x = x, y = inc.y(tableSpacing.row*1.5), min = 0, max = 255, vals = { 1 }, scale = 100 }
        inc.y(tableSpacing.row*0.5)
    end
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 255, vals = { 12 }, scale = 100 }

    x = x + tableSpacing.col
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = "Super", x = x, y = inc.y(tableSpacing.header) }
    labels[#labels + 1] = { t = "Rate",  x = x, y = inc.y(tableSpacing.header) }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 3 }, scale = 100 }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 4 }, scale = 100 }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 255, vals = { 5 }, scale = 100 }

    x = x + tableSpacing.col
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = "RC",    x = x, y = inc.y(tableSpacing.header) }
    labels[#labels + 1] = { t = "Expo",  x = x, y = inc.y(tableSpacing.header) }
    if apiVersion >= 1.037 then
        fields[#fields + 1] = {          x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 2 }, scale = 100 }
        fields[#fields + 1] = {          x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 14 }, scale = 100 }
    else
        fields[#fields + 1] = {          x = x, y = inc.y(tableSpacing.row*1.5), min = 0, max = 100, vals = { 2 }, scale = 100 }
        inc.y(tableSpacing.row*0.5)
    end    
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 11 }, scale = 100 }
    
    x = margin
    inc.y(lineSpacing*0.4)
end

if apiVersion >= 1.016 then
    labels[#labels + 1] = { t = "Throttle",       x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Mid",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100, vals = { 7 }, scale = 100 }
    fields[#fields + 1] = { t = "Expo",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100, vals = { 8 }, scale = 100 }
    if apiVersion >= 1.041 then
        fields[#fields + 1] = { t = "Limit Type", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2, vals = { 15 }, table = { [0] = "OFF", "SCALE", "CLIP" } }
        fields[#fields + 1] = { t = "Limit %",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 25, max = 100, vals = { 16 } }
    end
end

if apiVersion >= 1.016 then
    labels[#labels + 1] = { t = "TPA",            x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Rate",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100, vals = { 6 } , scale = 100 }
    fields[#fields + 1] = { t = "Breakpoint",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1000, max = 2000, vals = { 9, 10 } }
end

return {
    read        = 111, -- MSP_RC_TUNING
    write       = 204, -- MSP_SET_RC_TUNING
    title       = "Rates",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 12,
    labels      = labels,
    fields      = fields,
}
