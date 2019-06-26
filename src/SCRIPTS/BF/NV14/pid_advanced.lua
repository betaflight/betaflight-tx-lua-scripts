return {
    read           = 94, -- MSP_PID_ADVANCED
    write          = 95, -- MSP_SET_PID_ADVANCED
    title          = "PID Advanced",
    reboot         = false,
    eepromWrite    = true,
    minBytes       = 46,
    outputBytes    = 46,
    yMinLimit      = 35,
    yMaxLimit      = 215,
    text = {
        { t = "Acro Trainer",      x = 5,  y = 35 },
        { t = "Angle Limit",       x = 15, y = 55, to = SMLSIZE },

        { t = "Throttle Boost",    x = 5,  y = 75 },
        { t = "Absolute Control",  x = 5,  y = 95 },
        { t = "I Term Rotation",   x = 5,  y = 115 },
        { t = "VBAT Compensation", x = 5,  y = 135 },

        { t = "I Term Relax",      x = 5,  y = 155 },
        { t = "Axes",              x = 15, y = 175, to = SMLSIZE },
        { t = "Type",              x = 15, y = 195, to = SMLSIZE },

        { t = "Integrated Yaw",    x = 5,  y = 215 },

        { t = "Anti Gravity",      x = 5,  y = 235 },
        { t = "Mode",              x = 15, y = 255, to = SMLSIZE },
        { t = "Gain",              x = 15, y = 275, to = SMLSIZE },
        { t = "Threshold",         x = 15, y = 295, to = SMLSIZE },
    },
    fields = {
        { x = 200, y = 55,  min = 20,   max = 80,    vals = { 32 } },

        { x = 200, y = 75,  min = 0,    max = 100,   vals = { 31 } },
        { x = 200, y = 95,  min = 0,    max = 20,    vals = { 30 } },
        { x = 200, y = 115, min = 0,    max = 1,     vals = { 26 }, table = { [0]="OFF", "ON" } },
        { x = 200, y = 135, min = 0,    max = 1,     vals = { 8 },  table = { [0]="OFF", "ON" } },

        { x = 200, y = 175, min = 0,    max = 4,     vals = { 28 }, table = { [0]="NONE", "RP", "RPY", "RP (increment only)", "RPY (increment only)" } },
        { x = 200, y = 195, min = 0,    max = 1,     vals = { 29 }, table = { [0]="Gyro", "Setpoint" } },

        { x = 200, y = 215, min = 0,    max = 1,     vals = { 45 }, table = { [0]="OFF", "ON" } },

        { x = 200, y = 255, min = 0,    max = 1,     vals = { 39 }, table = { [0]="Smooth", "Step" } },
        { x = 200, y = 275, min = 1000, max = 30000, vals = { 22, 23 }, scale = 1000, mult = 100 },
        { x = 200, y = 295, min = 20,   max = 1000,  vals = { 20, 21 } },
    }
}
