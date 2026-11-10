local template = assert(loadScript(radio.template))()
local margin = template.margin
local lineSpacing = template.lineSpacing
local yMinLim = radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local inc = { x = function(val) x = x + val return x end, y = function(val) y = y + val return y end }
local labels = {}
local fields = {}

labels[#labels + 1] = { t = "All blackbox logs on the",   x = x, y = inc.y(lineSpacing) }
labels[#labels + 1] = { t = "flash will be deleted.",     x = x, y = inc.y(lineSpacing) }
labels[#labels + 1] = { t = "Press [ENTER] to erase, or", x = x, y = inc.y(lineSpacing) }
labels[#labels + 1] = { t = "[EXIT] to cancel.",          x = x, y = inc.y(lineSpacing) }
fields[#fields + 1] = { x = x, y = inc.y(lineSpacing), value = "", ro = true }

return {
    title  = "Erase Blackbox",
    labels = labels,
    fields = fields,
    init   = assert(loadScript("blackbox_erase.lua"))(),
}
