local template = loadScript(radio.templateHome.."pids1.lua")
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
    x = margin
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = "",      x = x, y = inc.y(tableSpacing.header) }
    labels[#labels + 1] = { t = "ROLL",  x = x, y = inc.y(tableSpacing.row) }
    labels[#labels + 1] = { t = "PITCH", x = x, y = inc.y(tableSpacing.row) }
    labels[#labels + 1] = { t = "YAW",   x = x, y = inc.y(tableSpacing.row) }

    x = x + tableSpacing.col
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = "P",     x = x, y = inc.y(tableSpacing.header) }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 200, vals = { 1 } }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 200, vals = { 4 } }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 200, vals = { 7 } }

    x = x + tableSpacing.col
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = "I",     x = x, y = inc.y(tableSpacing.header) }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 200, vals = { 2 } }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 200, vals = { 5 } }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 200, vals = { 8 } }

    x = x + tableSpacing.col
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = "D",     x = x, y = inc.y(tableSpacing.header) }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 200, vals = { 3 } }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 200, vals = { 6 } }
    if apiVersion >= 1.041 then
        fields[#fields + 1] = {          x = x, y = inc.y(tableSpacing.row), min = 0, max = 200, vals = { 9 } }
    end
end

return {
    read        = 112, -- MSP_PID
    write       = 202, -- MSP_SET_PID
    title       = "PIDs (1/2)",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 9,
    labels      = labels,
    fields      = fields,
}
