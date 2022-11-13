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

labels[#labels + 1] = { t = "Trim Accelerometer",   x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Pitch",                x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -300, max = 300, vals = { 1, 2 } }
fields[#fields + 1] = { t = "Roll",                 x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -300, max = 300, vals = { 3, 4 } }

return {
    read        = 240, -- MSP_ACC_TRIM
    write       = 239, -- MSP_SET_ACC_TRIM         
    title       = "Acc",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 4,
    labels      = labels,
    fields      = fields,
    postLoad = function(self)
        temp_pitch=bit32.lshift(self.values[1], (1-1)*8)+bit32.lshift(self.values[2], (2-1)*8)
        if temp_pitch >= 65000 then
            self.fields[1].value = math.floor(temp_pitch-65536)
        end
        temp_roll=bit32.lshift(self.values[3], (1-1)*8)+bit32.lshift(self.values[4], (2-1)*8)
        if temp_roll >= 65000 then
            self.fields[2].value = math.floor(temp_roll-65536)
        end
    end,
}
