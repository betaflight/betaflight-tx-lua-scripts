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

labels[#labels + 1] = { t = "Download VTX tables? Press", x = x, y = inc.y(lineSpacing) }
labels[#labels + 1] = { t = "[ENTER] to download, or",    x = x, y = inc.y(lineSpacing) }
labels[#labels + 1] = { t = "[EXIT] to cancel.",          x = x, y = inc.y(lineSpacing) }
fields[#fields + 1] = { x = x, y = inc.y(lineSpacing), value = "", ro = true }

return {
    title  = "VTX Tables",
    labels = labels,
    fields = fields,
    init   = assert(loadScript("vtx_tables.lua"))(),
}
