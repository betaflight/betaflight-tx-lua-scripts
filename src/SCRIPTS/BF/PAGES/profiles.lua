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

local RATEPROFILE_MASK = bit32.lshift(1, 7)
local profileNumbers = { [0] = "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }

fields[#fields + 1] = { t = "PID Profile", x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 11 }, table = profileNumbers }
fields[#fields + 1] = { t = "Rate Profile", x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 5, vals = { 15 }, table = profileNumbers }

return {
    read        = 150, -- MSP_STATUS_EX
    write       = 210, -- MSP_SELECT_SETTING
    title       = "Profiles",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 11,
    labels      = labels,
    fields      = fields,
    pidProfile = 0,
    postLoad = function(self)
        local pidProfileCount = self.values[14]
        self.fields[1].max = pidProfileCount - 1
        self.pidProfile = self.fields[1].value
    end,
    preSave = function(self)
        local value = 0
        if self.fields[1].value ~= self.pidProfile then
            value = self.fields[1].value
        else
            value = bit32.bor(self.fields[2].value, RATEPROFILE_MASK)
        end
        self.values = {}
        self.values[1] = value
        return self.values
    end,
}
