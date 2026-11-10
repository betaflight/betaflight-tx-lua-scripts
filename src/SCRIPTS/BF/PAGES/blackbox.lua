local template = assert(loadScript(radio.template))()
local margin = template.margin
local lineSpacing = template.lineSpacing
local sp = template.listSpacing.field
local yMinLim = radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local inc = { x = function(val) x = x + val return x end, y = function(val) y = y + val return y end }
local labels = {}
local fields = {}

local FLAG_READY     = 1
local FLAG_SUPPORTED = 2

-- MSP_DATAFLASH_SUMMARY: flags (U8), sectors (U32), total size (U32), used size (U32).
-- The sizes are 32-bit, so they are decoded in postLoad rather than through `vals`,
-- and shown as text.
fields[#fields + 1] = { t = "Flash", x = x, y = inc.y(lineSpacing), sp = x + sp, ro = true }
fields[#fields + 1] = { t = "Used",  x = x, y = inc.y(lineSpacing), sp = x + sp, ro = true }
fields[#fields + 1] = { t = "Free",  x = x, y = inc.y(lineSpacing), sp = x + sp, ro = true }
fields[#fields + 1] = { t = "Total", x = x, y = inc.y(lineSpacing), sp = x + sp, ro = true }

local function readU32(buf, i)
    return (buf[i] or 0) + (buf[i + 1] or 0) * 256 + (buf[i + 2] or 0) * 65536 + (buf[i + 3] or 0) * 16777216
end

local function formatSize(bytes)
    if bytes >= 1048576 then
        return string.format("%.1f MB", bytes / 1048576)
    end
    return string.format("%d kB", math.floor(bytes / 1024 + 0.5))
end

return {
    read     = 70, -- MSP_DATAFLASH_SUMMARY
    title    = "Blackbox",
    minBytes = 13,
    labels   = labels,
    fields   = fields,
    supported = false,
    postLoad = function(self)
        -- A truncated reply would decode as wrong sizes; drop it so the
        -- controller asks again.
        if #self.values < self.minBytes then
            self.values = nil
            return
        end
        local flags = self.values[1] or 0
        self.supported = bit32.btest(flags, FLAG_SUPPORTED)
        if not self.supported then
            self.fields[1].value = "None"
            for i = 2, #self.fields do
                self.fields[i].value = "---"
            end
            return
        end
        local total = readU32(self.values, 6)
        local used = readU32(self.values, 10)
        local free = total - used
        if free < 0 then
            free = 0
        end
        local pct = 0
        if total > 0 then
            pct = math.floor(used * 100 / total + 0.5)
        end
        self.fields[1].value = bit32.btest(flags, FLAG_READY) and "Ready" or "Busy"
        self.fields[2].value = formatSize(used) .. " (" .. pct .. "%)"
        self.fields[3].value = formatSize(free)
        self.fields[4].value = formatSize(total)
    end,
    -- Offered by the renderer next to (or instead of) "save page"; only once the
    -- FC has said it has a flash chip to erase.
    actions = function(self)
        if not (self.values and self.supported) then
            return {}
        end
        return {
            { t = "erase flash", title = "Erase Blackbox Flash", confirm = "CONFIRM/blackbox_erase.lua" },
        }
    end,
}
