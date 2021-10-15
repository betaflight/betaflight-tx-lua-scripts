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

local pidMax = 200
local dLabel = "D"

if apiVersion >= 1.044 then
    pidMax = 250
    dLabel = "D Max"
end

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
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = pidMax, vals = { 1 } }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = pidMax, vals = { 4 } }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = pidMax, vals = { 7 } }

    x = x + tableSpacing.col
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = "I",     x = x, y = inc.y(tableSpacing.header) }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = pidMax, vals = { 2 } }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = pidMax, vals = { 5 } }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = pidMax, vals = { 8 } }

    x = x + tableSpacing.col
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = dLabel,  x = x, y = inc.y(tableSpacing.header) }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = pidMax, vals = { 3 } }
    fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = pidMax, vals = { 6 } }
    if apiVersion >= 1.041 then
        fields[#fields + 1] = {          x = x, y = inc.y(tableSpacing.row), min = 0, max = pidMax, vals = { 9 } }
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
