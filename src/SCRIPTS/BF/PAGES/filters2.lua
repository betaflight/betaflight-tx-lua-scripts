local template = loadScript(radio.templateHome.."filters2.lua")
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

if apiVersion >= 1.042 then
    labels[#labels + 1] = { t = "Gyro RPM Filter",      x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Harmonics",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 3, vals = { 44 } }
    fields[#fields + 1] = { t = "Min Frequency",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 50, max = 200, vals = { 45 } }
    labels[#labels + 1] = { t = "Dynamic Notch Filter", x = x,          y = inc.y(lineSpacing) }
    if apiVersion < 1.043 then
        fields[#fields + 1] = { t = "Range",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 3, vals = { 38 }, table = { [0]="HIGH", "MEDIUM", "LOW", "AUTO" } }
    end
    fields[#fields + 1] = { t = "Width %",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 20, vals = { 39 } }
    fields[#fields + 1] = { t = "Q",                    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 1000, vals = { 40, 41 } }
    if apiVersion >= 1.043 then
        fields[#fields + 1] = { t = "Min Frequency",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 60, max = 250, vals = { 42, 43 } }
        fields[#fields + 1] = { t = "Max Frequency",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 200, max = 1000, vals = { 46, 47 } }
    else
        fields[#fields + 1] = { t = "Min Frequency",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 60, max = 1000, vals = { 42, 43 } }
    end
end

return {
    read        = 92, -- MSP_FILTER_CONFIG
    write       = 93, -- MSP_SET_FILTER_CONFIG
    eepromWrite = true,
    reboot      = false,
    title       = "Filters (2/2)",
    minBytes    = 5,
    labels      = labels,
    fields      = fields,
    postLoad = function(self)
        self.rpmHarmonics = self.values[44]
    end,
    preSave = function(self)
        self.reboot = self.values[44] == 0 and self.rpmHarmonics ~= 0
        return self.values
    end,
}
