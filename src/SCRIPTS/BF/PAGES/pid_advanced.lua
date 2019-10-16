local display = assert(loadScript(radio.templateHome.."pid_advanced.lua"))()
return {
    read            = 94, -- MSP_PID_ADVANCED
    write           = 95, -- MSP_SET_PID_ADVANCED
    title           = "PID Advanced",
    reboot          = false,
    eepromWrite     = true,
    minBytes        = 46,
    outputBytes     = 46,
    text            = display.text,
    fieldLayout     = display.fieldLayout,
    fields          = {
        { min = 20,   max = 80,    vals = { 32 } },
        { min = 0,    max = 100,   vals = { 31 } },
        { min = 0,    max = 20,    vals = { 30 } },
        { min = 0,    max = 1,     vals = { 26 }, table = { [0]="OFF", "ON" } },
        { min = 0,    max = 1,     vals = { 8 },  table = { [0]="OFF", "ON" } },
        { min = 0,    max = 4,     vals = { 28 }, table = { [0]="NONE", "RP", "RPY", "RP (inc)", "RPY (inc)" } },
        { min = 0,    max = 1,     vals = { 29 }, table = { [0]="Gyro", "Setpoint" } },
        { min = 0,    max = 1,     vals = { 45 }, table = { [0]="OFF", "ON" } },
        { min = 0,    max = 1,     vals = { 39 }, table = { [0]="Smooth", "Step" } },
        { min = 1000, max = 30000, vals = { 22, 23 }, scale = 1000, mult = 100 },
        { min = 20,   max = 1000,  vals = { 20, 21 } },
    }
}