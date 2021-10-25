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

if apiVersion >= 1.041 then
    fields[#fields + 1] = { t = "Min Sats.",        x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 50, vals = { 16 } }
    fields[#fields + 1] = { t = "Angle",            x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 1, 2 } }
    fields[#fields + 1] = { t = "Initial Altitude", x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 20, max = 100, vals = { 3, 4 } }
    fields[#fields + 1] = { t = "Descent Distance", x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 30, max = 500, vals = { 5, 6 } }
    fields[#fields + 1] = { t = "Ground Speed",     x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 30, max = 3000, vals = { 7, 8 } }

    if apiVersion >= 1.043 then
        fields[#fields + 1] = { t = "Ascend Rate",  x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 100, max = 2500, vals = { 17, 18 }, scale = 100 }
        fields[#fields + 1] = { t = "Descend Rate", x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 100, max = 500, vals = { 19, 20 }, scale = 100 }
        fields[#fields + 1] = { t = "Arm w/o fix",  x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 21 }, table = { [0]="OFF","ON"} }
        fields[#fields + 1] = { t = "Altitude Mode",x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2, vals = { 22 }, table = { [0]="Maximum", "Fixed", "Current"} }
    end

    fields[#fields + 1] = { t = "Sanity Check",     x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2, vals = { 15 }, table = { [0]="OFF","ON","FS_ONLY"} }
    labels[#labels + 1] = { t = "Throttle",         x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Min",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1000, max = 2000, vals = { 9, 10 } }
    fields[#fields + 1] = { t = "Hover",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1000, max = 2000, vals = { 13, 14 } }
    fields[#fields + 1] = { t = "Max",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1000, max = 2000, vals = { 11, 12 } }

    if apiVersion >= 1.044 then
        fields[#fields + 1] = { t = "Min Dth",      x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 50, max = 1000, vals = { 23, 24 } }
    end
end

return {
   read        = 135, -- MSP_GPS_RESCUE
   write       = 225, -- MSP_SET_GPS_RESCUE
   title       = "GPS Rescue",
   reboot      = false,
   eepromWrite = true,
   minBytes    = 16,
   labels      = labels,
   fields      = fields,
}
