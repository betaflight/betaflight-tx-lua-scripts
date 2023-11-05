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

if apiVersion >= 1.45 then
    fields[#fields + 1] = { t = "flags",      x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2, vals = { 1 }, table = { [0] = "NOT_SUPPORTED", "SUPPORTED" } }
    fields[#fields + 1] = { t = "state",      x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4, vals = { 2 }, table = { [0] = "NOT_PRESENT", "FATAL", "CARD_INIT", "FS_INIT", "READY" } }
    fields[#fields + 1] = { t = "lastError",  x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 9, vals = { 3 } }
    fields[#fields + 1] = { t = "freeSpace MB",  x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 9999999999, vals = { 4, 5, 6, 7 }, scale = 1024, upd = function(self) self.updateItems(self) end }
    fields[#fields + 1] = { t = "totalSpace MB", x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 9999999999, vals = { 8, 9, 10, 11 }, scale = 1024 }
end

return {
    read        = 79, -- MSP_SDCARD_SUMMARY
    -- write       = 72, -- MSP_DATAFLASH_ERASE
    title       = "Blackbox Info",
    reboot      = false,
    eepromWrite = false,
    minBytes    = 0,
    labels      = labels,
    fields      = fields,
    updateItems = function(self)
        self.fields[4].value = string.format("%.0f",self.fields[4].value)
    end,
}
