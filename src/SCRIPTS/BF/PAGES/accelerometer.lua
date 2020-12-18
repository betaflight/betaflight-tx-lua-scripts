local template = loadScript(radio.templateHome.."accelerometer.lua")
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

labels[#labels + 1] = { t = "Make sure the craft is level", x = x, y = inc.y(lineSpacing) }
labels[#labels + 1] = { t = "and stable, then press",       x = x, y = inc.y(lineSpacing) }
labels[#labels + 1] = { t = "[ENTER] to calibrate, or",     x = x, y = inc.y(lineSpacing) }
labels[#labels + 1] = { t = "[EXIT] to cancel.",            x = x, y = inc.y(lineSpacing) }
fields[#fields + 1] = { x = x, y = inc.y(lineSpacing), value = "", ro = true, onClick = function(self) self.accCal(self) end }

return {
    write       = 205, -- MSP_ACC_CALIBRATION
    title       = "Accelerometer",
    reboot      = false,
    eepromWrite = false,
    minBytes    = 0,
    labels      = labels,
    fields      = fields,
    accCal = function(self)
        protocol.mspRead(self.write)
    end,
}
