local template = loadScript(radio.templateHome.."rx.lua")
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
    labels[#labels + 1] = { t = "Stick",      x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Low",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1000, max = 2000, vals = { 6, 7 } }
    fields[#fields + 1] = { t = "Center",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1000, max = 2000, vals = { 4, 5 } }
    fields[#fields + 1] = { t = "High",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1000, max = 2000, vals = { 2, 3 } }
end

if apiVersion >= 1.020 then
    fields[#fields + 1] = { t = "Interp",     x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 3, vals = { 13 }, table={ [0]="Off", "Preset", "Auto", "Manual"} }
    fields[#fields + 1] = { t = "Interp Int", x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 50, vals = { 14 } }
end

if apiVersion >= 1.031 then
    fields[#fields + 1] = { t = "Cam Angle",  x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 90, vals = { 23 } }
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
