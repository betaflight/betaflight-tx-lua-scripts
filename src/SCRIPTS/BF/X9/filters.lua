
return {
    read              = 92, -- MSP_FILTER_CONFIG
    write             = 93, -- MSP_SET_FILTER_CONFIG
    eepromWrite       = true,
    reboot            = false,
    title             = "Filters",
    minBytes          = 18,
    text= {
        { t = "LPF", x = 43, y = 14, to = SMLSIZE },
        { t = "Gyro", x = 15, y = 24, to = SMLSIZE },
        { t = "DTerm", x = 10, y = 34, to = SMLSIZE },
        { t = "Yaw", x = 20, y = 44, to = SMLSIZE },
        { t = "Gyro 1", x = 75, y = 14, to = SMLSIZE },
        { t = "Hz", x = 68, y = 24, to = SMLSIZE },
        { t = "CO", x = 68, y = 34, to = SMLSIZE },
        { t = "Gyro 2", x = 120, y = 14, to = SMLSIZE },
        { t = "Hz", x = 113, y = 24, to = SMLSIZE },
        { t = "CO", x = 113, y = 34, to = SMLSIZE },
        { t = "DTerm", x = 168, y = 14, to = SMLSIZE },
        { t = "Hz", x = 158, y = 24, to = SMLSIZE },
        { t = "CO", x = 158, y = 34, to = SMLSIZE },
        { t = "DTerm LP Type", x = 108, y = 44, to = SMLSIZE },
    },
    fields = {
        { x = 38,  y = 24, min = 0, max = 255,   to = SMLSIZE, vals = { 1 } },
        { x = 38,  y = 34, min = 0, max = 16000, to = SMLSIZE, vals = { 2, 3 } },
        { x = 38,  y = 44, min = 0, max = 500,   to = SMLSIZE, vals = { 4, 5 } },
        { x = 81,  y = 24, min = 0, max = 16000, to = SMLSIZE, vals = { 6, 7 } },
        { x = 81,  y = 34, min = 0, max = 16000, to = SMLSIZE, vals = { 8, 9 } },
        { x = 126, y = 24, min = 0, max = 16000, to = SMLSIZE, vals = { 14, 15 } },
        { x = 126, y = 34, min = 0, max = 16000, to = SMLSIZE, vals = { 16, 17 } },
        { x = 171, y = 24, min = 0, max = 16000, to = SMLSIZE, vals = { 10, 11 } },
        { x = 171, y = 34, min = 0, max = 16000, to = SMLSIZE, vals = { 12, 13 } },
        { x = 171, y = 44, min = 0, max = 2,     to = SMLSIZE, vals = { 18 }, table = { [0] = "PT1", [1] = "BIQUAD", [2] = "FIR" } },
    }
}
