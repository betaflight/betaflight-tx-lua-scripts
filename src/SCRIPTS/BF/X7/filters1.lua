
return {
    read              = 92, -- MSP_FILTER_CONFIG
    write             = 93, -- MSP_SET_FILTER_CONFIG
    eepromWrite       = true,
    reboot            = false,
    title             = "Filt (1/2)",
    minBytes          = 18,
    outputBytes       = 18,
    text= {
        { t = "LPF", x = 43, y = 14, to = SMLSIZE },
        { t = "Gyro", x = 20, y = 24, to = SMLSIZE },
        { t = "DTerm", x = 15, y = 34, to = SMLSIZE },
        { t = "Yaw", x = 25, y = 44, to = SMLSIZE },
        { t = "Gyro 1", x = 75, y = 14, to = SMLSIZE },
        { t = "Hz", x = 73, y = 24, to = SMLSIZE },
        { t = "CO", x = 73, y = 34, to = SMLSIZE },
    },
    fields = {
        { x = 43,  y = 24, min = 0, max = 255,   to = SMLSIZE, vals = { 1 } },
        { x = 43,  y = 34, min = 0, max = 16000, to = SMLSIZE, vals = { 2, 3 } },
        { x = 43,  y = 44, min = 0, max = 500,   to = SMLSIZE, vals = { 4, 5 } },
        { x = 85,  y = 24, min = 0, max = 16000, to = SMLSIZE, vals = { 6, 7 } },
        { x = 85,  y = 34, min = 0, max = 16000, to = SMLSIZE, vals = { 8, 9 } },
    }
}
