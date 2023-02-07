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

if apiVersion >= 1.40 then
    labels[#labels + 1] = { t = "Acro Trainer",      x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Angle Limit",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 20, max = 80, vals = { 32 } }
    fields[#fields + 1] = { t = "Throttle Boost",    x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100, vals = { 31 } }
    fields[#fields + 1] = { t = "Absolute Control",  x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 20, vals = { 30 } }
    fields[#fields + 1] = { t = "I Term Rotation",   x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 26 }, table = { [0] = "OFF", "ON" } }
end

if apiVersion >= 1.43 then
    fields[#fields + 1] = { t = "Motor Output Limit",x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 100, vals = { 48 } }
    if apiVersion >= 1.45 then
        fields[#fields + 1] = { t = "Dynamic Idle",  x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 50 } }
    else
        fields[#fields + 1] = { t = "Dynamic Idle",  x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100, vals = { 50 } }
    end
end

if apiVersion >= 1.16 and apiVersion <= 1.43 then
    fields[#fields + 1] = { t = "VBAT Compensation", x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 8 },  table = { [0] = "OFF", "ON" } }
end

if apiVersion >= 1.44 then
    fields[#fields + 1] = { t = "Vbat Sag Comp",     x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 150, vals = { 56 } }
    fields[#fields + 1] = { t = "Thrust Linear",     x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 150, vals = { 57 } }
end

if apiVersion >= 1.45 then
    labels[#labels + 1] = { t = "TPA",               x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Mode",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 58 }, table = { [0] = "PD", "D" } }
    fields[#fields + 1] = { t = "Rate",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100, vals = { 59 } , scale = 100 }
    fields[#fields + 1] = { t = "Breakpoint",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 750, max = 2250, vals = { 60, 61 } }
end

if apiVersion >= 1.40 and apiVersion <= 1.41 then
    fields[#fields + 1] = { t = "Smart Feedforward", x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 27 }, table = { [0] = "OFF", "ON" } } 
end

if apiVersion >= 1.41 then
    fields[#fields + 1] = { t = "Integrated Yaw",    x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 45 }, table = { [0] = "OFF", "ON" } }
end

if apiVersion >= 1.40 then
    labels[#labels + 1] = { t = "I Term Relax",      x = x,          y = inc.y(lineSpacing) }
    fields[#fields + 1] = { t = "Axes",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4, vals = { 28 }, table = { [0] = "NONE", "RP", "RPY", "RP (inc)", "RPY (inc)" } }
    fields[#fields + 1] = { t = "Type",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 29 }, table = { [0] = "Gyro", "Setpoint" } }
    if apiVersion >= 1.43 then
        fields[#fields + 1] = { t = "Cutoff",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 50, vals = { 47 } }
    elseif apiVersion >= 1.42 then
        fields[#fields + 1] = { t = "Cutoff",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 100, vals = { 47 } }
    end
end

if apiVersion >= 1.36 then
    labels[#labels + 1] = { t = "Anti Gravity",      x = x,          y = inc.y(lineSpacing) }
    if apiVersion >= 1.40 and apiVersion <= 1.44 then
        fields[#fields + 1] = { t = "Mode",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 39 }, table = { [0] = "Smooth", "Step" } }
    end
    if apiVersion >= 1.45 then
        fields[#fields + 1] = { t = "Gain",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 22, 23 }, scale = 10 }
    elseif apiVersion >= 1.44 then
        fields[#fields + 1] = { t = "Gain",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 30000, vals = { 22, 23 }, scale = 1000, mult = 100 }
    else
        fields[#fields + 1] = { t = "Gain",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1000, max = 30000, vals = { 22, 23 }, scale = 1000, mult = 100 }
    end
    if apiVersion <= 1.44 then
        fields[#fields + 1] = { t = "Threshold",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 20, max = 1000, vals = { 20, 21 } }
    end
end

return {
    read        = 94, -- MSP_PID_ADVANCED
    write       = 95, -- MSP_SET_PID_ADVANCED
    title       = "PID Advanced",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 8,
    labels      = labels,
    fields      = fields,
    postLoad = function(self)
        self.dynamicIdle = self.values[50]
    end,
    preSave = function(self)
        self.reboot = self.values[50] ~= self.dynamicIdle and apiVersion <= 1.43
        return self.values
    end,
}
