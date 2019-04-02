return {
    read              = 92, -- MSP_FILTER_CONFIG
    write             = 93, -- MSP_SET_FILTER_CONFIG
    eepromWrite       = true,
    reboot            = false,
    title             = "Filters",
    minBytes          = 37,
    outputBytes       = 37,
    yMinLimit         = 35,
    yMaxLimit         = 215,
    text= {
        { t = "Gyro Lowpass 1 Dynamic",   x = 5,  y = 35 },
        { t = "Min Cutoff",               x = 35, y = 55,  to = SMLSIZE },
        { t = "Max Cutoff",               x = 35, y = 75,  to = SMLSIZE },
        { t = "Filter Type",              x = 35, y = 95,  to = SMLSIZE },

        { t = "Gyro Lowpass 1",           x = 5,  y = 115 },
        { t = "Cutoff",                   x = 35, y = 135, to = SMLSIZE },
        { t = "Filter Type",              x = 35, y = 155, to = SMLSIZE },

        { t = "Gyro Lowpass 2",           x = 5,  y = 175 },
        { t = "Cutoff",                   x = 35, y = 195, to = SMLSIZE },
        { t = "Filter Type",              x = 35, y = 215, to = SMLSIZE },

        { t = "Gyro Notch 1",             x = 5,  y = 235 },
        { t = "Center",                   x = 35, y = 255, to = SMLSIZE },
        { t = "Cutoff",                   x = 35, y = 275, to = SMLSIZE },

        { t = "Gyro Notch 2",             x = 5,  y = 295 },
        { t = "Center",                   x = 35, y = 315, to = SMLSIZE },
        { t = "Cutoff",                   x = 35, y = 335, to = SMLSIZE },

        { t = "D Term Lowpass 1 Dynamic", x = 5,  y = 355 },
        { t = "Min Cutoff",               x = 35, y = 375, to = SMLSIZE },
        { t = "Max Cutoff",               x = 35, y = 395, to = SMLSIZE },
        { t = "Filter Type",              x = 35, y = 415, to = SMLSIZE },

        { t = "D Term Lowpass 1",         x = 5,  y = 435 },
        { t = "Cutoff",                   x = 35, y = 455, to = SMLSIZE },
        { t = "Filter Type",              x = 35, y = 475, to = SMLSIZE },

        { t = "D Term Lowpass 2",         x = 5,  y = 495 },
        { t = "Cutoff",                   x = 35, y = 515, to = SMLSIZE },
        { t = "Filter Type",              x = 35, y = 535, to = SMLSIZE },

        { t = "D Term Notch",             x = 5,  y = 555 },
        { t = "Center",                   x = 35, y = 575, to = SMLSIZE },
        { t = "Cutoff",                   x = 35, y = 595, to = SMLSIZE },

        { t = "Yaw Lowpass",              x = 5,  y = 615 },
        { t = "Cutoff",                   x = 35, y = 635, to = SMLSIZE },
    },
    fields = {
        -- Gyro Lowpass 1 Dynamic
        { x = 200, y = 55,  min = 0, max = 1000,  vals = { 30, 31 } },
        { x = 200, y = 75,  min = 0, max = 1000,  vals = { 32, 33 } },
        { x = 200, y = 95,  min = 0, max = 1,     vals = { 25 }, table = { [0] = "PT1", [1] = "BIQUAD" } },

        -- Gyro Lowpass 1
        { x = 200, y = 135, min = 0, max = 16000, vals = { 21, 22 } },
        { x = 200, y = 155, min = 0, max = 1,     vals = { 25 }, table = { [0] = "PT1", [1] = "BIQUAD" } },

        -- Gyro Lowpass 2
        { x = 200, y = 195, min = 0, max = 16000, vals = { 23, 24 } },
        { x = 200, y = 215, min = 0, max = 1,     vals = { 26 }, table = { [0] = "PT1", [1] = "BIQUAD" } },

        -- Gyro Notch 1
        { x = 200, y = 255, min = 0, max = 16000, vals = { 6, 7 } },
        { x = 200, y = 275, min = 0, max = 16000, vals = { 8, 9 } },

        -- Gyro Notch 2
        { x = 200, y = 315, min = 0, max = 16000, vals = { 14, 15 } },
        { x = 200, y = 335, min = 0, max = 16000, vals = { 16, 17 } },

        -- D Term Lowpass 1 Dynamic
        { x = 200, y = 375, min = 0, max = 1000,  vals = { 34, 35 } },
        { x = 200, y = 395, min = 0, max = 1000,  vals = { 36, 37 } },
        { x = 200, y = 415, min = 0, max = 1,     vals = { 18 }, table = { [0] = "PT1", [1] = "BIQUAD" } },

        -- D Term Lowpass 1
        { x = 200, y = 455, min = 0, max = 16000, vals = { 2, 3 } },
        { x = 200, y = 475, min = 0, max = 1,     vals = { 18 }, table = { [0] = "PT1", [1] = "BIQUAD" } },

        -- D Term Lowpass 2
        { x = 200, y = 515, min = 0, max = 16000, vals = { 27, 28 } },
        { x = 200, y = 535, min = 0, max = 1,     vals = { 29 }, table = { [0] = "PT1", [1] = "BIQUAD" } },

        -- D Term Notch
        { x = 200, y = 575, min = 0, max = 16000, vals = { 10, 11 } },
        { x = 200, y = 595, min = 0, max = 16000, vals = { 12, 13 } },

        -- Yaw Lowpass
        { x = 200, y = 635, min = 0, max = 500,   vals = { 4, 5 } },
    }
}
