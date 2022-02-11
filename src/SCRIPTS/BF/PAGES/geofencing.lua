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
    fields[#fields + 1] = { t = "Altitude",  x = x,         y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 1 }, table = { [0]="OFF","ON"} }
    fields[#fields + 1] = { t = "Distance",  x = x,         y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 2 }, table = { [0]="OFF","ON"} }
    fields[#fields + 1] = { t = "Altitude max",             x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 5, max = 500, vals = { 4, 5 } }
    fields[#fields + 1] = { t = "Alert bef alt max",        x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 50, vals = { 6 } }
    fields[#fields + 1] = { t = "Distance max",             x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 20, max = 2000, vals = { 7, 8 } }
    fields[#fields + 1] = { t = "Alert bef dis max",        x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 9 } }
    fields[#fields + 1] = { t = "Initial altitude",         x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 5000, vals = { 29 } }
    fields[#fields + 1] = { t = "Angle max",                x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 5000, vals = { 28 } }
    fields[#fields + 1] = { t = "Landing allowed",          x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 3 }, table = { [0]="OFF","ON"} }
    fields[#fields + 1] = { t = "Arm Without fix",          x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 31 }, table = { [0]="OFF","ON"} }
    fields[#fields + 1] = { t = "Min satellites",           x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 5000, vals = { 30 } }
    fields[#fields + 1] = { t = "Throttle MIN",             x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 5000, vals = { 16, 17 } }
    fields[#fields + 1] = { t = "Throttle MAX",             x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 5000, vals = { 18, 19 } }
    fields[#fields + 1] = { t = "Throttle HOVER",           x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 5000, vals = { 20, 21 } }
    fields[#fields + 1] = { t = "Throttle P",               x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 5000, vals = { 10, 11 } }
    fields[#fields + 1] = { t = "Throttle I",               x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 5000, vals = { 12, 13 } }
    fields[#fields + 1] = { t = "Throttle D",               x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 5000, vals = { 14, 15 } }
    fields[#fields + 1] = { t = "Geofence Pitch P",         x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 22 } }
    fields[#fields + 1] = { t = "Geofence Pitch I",         x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 23 } }
    fields[#fields + 1] = { t = "Geofence Pitch D",         x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 24 } }
    fields[#fields + 1] = { t = "Geofence Roll P",          x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 25 } }
    fields[#fields + 1] = { t = "Geofence Roll I",          x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 26 } }
    fields[#fields + 1] = { t = "Geofence Roll D",          x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 27 } }
end

return {
   read        = 133, -- MSP_VOLUME_LIMITATION
   write       = 224, -- MSP_SET_VOLUME_LIMITATION
   title       = "Geofencing",
   reboot      = false,
   eepromWrite = true,
   minBytes    = 16,
   labels      = labels,
   fields      = fields,
}

