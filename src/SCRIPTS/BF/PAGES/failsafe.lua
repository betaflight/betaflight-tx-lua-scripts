local template = loadScript(radio.templateHome.."failsafe.lua")
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

local procedure = { [0] = "Land", "Drop" }

if apiVersion >= 1.039 then
    procedure[#procedure + 1] = "Rescue"
end

if apiVersion >= 1.039 then
    labels[#labels + 1] = { t = "Failsafe Switch",   x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Action",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2, vals = { 5 }, table = { [0] = "Stage 1", "Kill", "Stage 2" } }
else
    fields[#fields + 1] = { t = "Kill switch",       x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 5 }, table = { [0] = "OFF", "ON" } }
end

labels[#labels + 1] = { t = "Stage 2 Settings" ,     x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Procedure",             x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #procedure, vals = { 8 }, table = procedure }
fields[#fields + 1] = { t = "Guard Time",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 1 }, scale = 10 }
fields[#fields + 1] = { t = "Thrl Low Delay",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 300, vals = { 6, 7 }, scale = 10 }

labels[#labels + 1] = { t = "Stage 2 Land Settings", x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Thrl Land Value",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 750, max = 2250, vals = { 3, 4 } }
fields[#fields + 1] = { t = "Motor Off Delay",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 2 }, scale = 10 }

return {
   read        = 75, -- MSP_FAILSAFE_CONFIG
   write       = 76, -- MSP_SET_FAILSAFE_CONFIG
   title       = "Failsafe",
   reboot      = true,
   eepromWrite = true,
   minBytes    = 8,
   labels      = labels,
   fields      = fields,
}
