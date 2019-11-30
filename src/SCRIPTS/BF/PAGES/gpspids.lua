local template = loadScript(radio.templateHome.."gpspids.lua")
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

if apiVersion >= 1.041 then
    x = margin
    y = yMinLim - tableSpacing.header
    labels[#labels + 1] = { t = "",         x = x, y = inc.y(tableSpacing.header) }
    labels[#labels + 1] = { t = "Throttle", x = x, y = inc.y(tableSpacing.row) }
    labels[#labels + 1] = { t = "Velocity", x = x, y = inc.y(tableSpacing.row) }
    labels[#labels + 1] = { t = "Yaw",      x = x, y = inc.y(tableSpacing.row) }

    x = x + tableSpacing.col*1.3
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = "P",        x = x, y = inc.y(tableSpacing.header) }
    fields[#fields + 1] = {                 x = x, y = inc.y(tableSpacing.row), min = 0, max = 200, vals = { 1, 2 } }
    fields[#fields + 1] = {                 x = x, y = inc.y(tableSpacing.row), min = 0, max = 200, vals = { 7, 8 } }
    fields[#fields + 1] = {                 x = x, y = inc.y(tableSpacing.row), min = 0, max = 500, vals = { 13, 14 } }

    x = x + tableSpacing.col
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = "I",        x = x, y = inc.y(tableSpacing.header) }
    fields[#fields + 1] = {                 x = x, y = inc.y(tableSpacing.row), min = 0, max = 200, vals = { 3, 4 } }
    fields[#fields + 1] = {                 x = x, y = inc.y(tableSpacing.row), min = 0, max = 200, vals = { 9, 10 } }

    x = x + tableSpacing.col
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = "D",        x = x, y = inc.y(tableSpacing.header) }
    fields[#fields + 1] = {                 x = x, y = inc.y(tableSpacing.row), min = 0, max = 200, vals = { 5, 6 } }
    fields[#fields + 1] = {                 x = x, y = inc.y(tableSpacing.row), min = 0, max = 200, vals = { 11, 12 } }
end

return {
    read        = 136, -- MSP_GPS_RESCUE_PIDS
    write       = 226, -- MSP_SET_GPS_RESCUE_PIDS
    title       = "GPS Rescue / PIDs",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 14,
    labels      = labels,
    fields      = fields,
}
