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

local gyroFilterType = { [0] = "PT1", "BIQUAD" }

if apiVersion >= 1.044 then
    gyroFilterType[#gyroFilterType + 1] = "PT2"
    gyroFilterType[#gyroFilterType + 1] = "PT3"
end

local dtermFilterType = gyroFilterType

if apiVersion >= 1.036 and apiVersion <= 1.038 then
    dtermFilterType = { [0] = "PT1", "BIQUAD", "FIR" }
end

local dtermFilterType2 = gyroFilterType

if apiVersion >= 1.041 then
    labels[#labels + 1] = { t = "Gyro Lowpass 1 Dynamic",   x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Min Cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 30, 31 } }
    fields[#fields + 1] = { t = "Max Cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 32, 33 } }
    fields[#fields + 1] = { t = "Filter Type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #gyroFilterType, vals = { 25 }, table = gyroFilterType }
end

if apiVersion >= 1.016 then
    labels[#labels + 1] = { t = "Gyro Lowpass 1",           x = x,          y = inc.y(lineSpacing) }
    if apiVersion >= 1.039 then
        fields[#fields + 1] = { t = "Cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 16000, vals = { 21, 22 } }
        fields[#fields + 1] = { t = "Filter Type",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #gyroFilterType, vals = { 25 }, table = gyroFilterType }
    else
        fields[#fields + 1] = { t = "Cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 255, vals = { 1 } }
    end
end

if apiVersion >= 1.039 then
    labels[#labels + 1] = { t = "Gyro Lowpass 2",           x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 16000, vals = { 23, 24 } }
    fields[#fields + 1] = { t = "Filter Type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #gyroFilterType, vals = { 26 }, table = gyroFilterType }
end

if apiVersion >= 1.020 then
    labels[#labels + 1] = { t = "Gyro Notch 1",             x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Center",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 16000, vals = { 6, 7 } }
    fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 16000, vals = { 8, 9 } }
end

if apiVersion >= 1.021 then
    labels[#labels + 1] = { t = "Gyro Notch 2",             x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Center",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 16000, vals = { 14, 15 } }
    fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 16000, vals = { 16, 17 } }
end 

if apiVersion >= 1.041 then
    labels[#labels + 1] = { t = "D Term Lowpass 1 Dynamic", x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Min Cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 34, 35 } }
    fields[#fields + 1] = { t = "Max Cutoff",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000, vals = { 36, 37 } }
    fields[#fields + 1] = { t = "Filter Type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #dtermFilterType, vals = { 18 }, table = dtermFilterType }
end

if apiVersion >= 1.016 then
    labels[#labels + 1] = { t = "D Term Lowpass 1",         x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 16000, vals = { 2, 3 } }
    if apiVersion >= 1.036 then
        fields[#fields + 1] = { t = "Filter Type",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #dtermFilterType, vals = { 18 }, table = dtermFilterType }
    end
end

if apiVersion >= 1.039 then
    labels[#labels + 1] = { t = "D Term Lowpass 2",         x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 16000, vals = { 27, 28 } }
    if apiVersion >= 1.041 then
        fields[#fields + 1] = { t = "Filter Type",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #dtermFilterType2, vals = { 29 }, table = dtermFilterType2 }
    end
end

if apiVersion >= 1.020 then
    labels[#labels + 1] = { t = "D Term Notch",             x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Center",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 16000, vals = { 10, 11 } }
    fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 16000, vals = { 12, 13 } }
end

if apiVersion >= 1.016 then
    labels[#labels + 1] = { t = "Yaw Lowpass",              x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Cutoff",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 500, vals = { 4, 5 } }
end

return {
    read        = 92, -- MSP_FILTER_CONFIG
    write       = 93, -- MSP_SET_FILTER_CONFIG
    eepromWrite = true,
    reboot      = false,
    title       = "Filters (1/2)",
    minBytes    = 5,
    labels      = labels,
    fields      = fields,
}
