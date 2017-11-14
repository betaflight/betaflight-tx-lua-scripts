
return {
    read              = 92, -- MSP_FILTER_CONFIG
    write             = 93, -- MSP_SET_FILTER_CONFIG
    eepromWrite       = true,
    reboot            = false,
    title             = "Filters",
    minBytes          = 18,
    text= {
        { t = "LPF",           x = 38, y = 68  },
        { t = "Gyro",          x = 12, y = 110 },
        { t = "DTerm",         x = 12, y = 155 },
        { t = "Yaw",           x = 12, y = 200 },
        
        { t = "Gyro 1",        x = 138, y = 68  },
        { t = "Hz",            x = 132, y = 110 },
        { t = "CO",            x = 132, y = 155 },

        { t = "Gyro 2",        x = 244, y = 68  },
        { t = "Hz",            x = 238, y = 110 },
        { t = "CO",            x = 238, y = 155 },

        { t = "DTerm",         x = 344, y = 68  },
        { t = "Hz",            x = 338, y = 110 },
        { t = "CO",            x = 338, y = 155 },

        { t = "DTerm LP Type", x = 148, y = 200 },
    },
    fields = {
        { x = 80,  y = 110, min = 0, max = 255,   vals = { 1 } },
        { x = 80,  y = 155, min = 0, max = 16000, vals = { 2, 3 } },
        { x = 80,  y = 200, min = 0, max = 500,   vals = { 4, 5 } },

        { x = 172, y = 110, min = 0, max = 16000, vals = { 6, 7 } },
        { x = 172, y = 155, min = 0, max = 16000, vals = { 8, 9 } },

        { x = 278, y = 110, min = 0, max = 16000, vals = { 14, 15 } },
        { x = 278, y = 155, min = 0, max = 16000, vals = { 16, 17 } },

        { x = 378, y = 110, min = 0, max = 16000, vals = { 10, 11 } },
        { x = 378, y = 155, min = 0, max = 16000, vals = { 12, 13 } },

        { x = 288, y = 200,  min = 0, max = 2,    vals = { 18 }, table = { [0] = "PT1", [1] = "BIQUAD", [2] = "FIR" } },
    }
}
