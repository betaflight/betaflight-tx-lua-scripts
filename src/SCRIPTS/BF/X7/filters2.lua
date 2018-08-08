
return {
    read              = 92, -- MSP_FILTER_CONFIG
    write             = 93, -- MSP_SET_FILTER_CONFIG
    eepromWrite       = true,
    reboot            = false,
    title             = "Filt (2/2)",
    minBytes          = 18,
    text= {
        { t = "Gyro 2", x = 30, y = 14, to = SMLSIZE },
        { t = "Hz", x = 28, y = 24, to = SMLSIZE },
        { t = "CO", x = 28, y = 34, to = SMLSIZE },
        { t = "DTerm", x = 73, y = 14, to = SMLSIZE },
        { t = "Hz", x = 73, y = 24, to = SMLSIZE },
        { t = "CO", x = 73, y = 34, to = SMLSIZE },
        { t = "DTerm LP Type", x = 18, y = 44, to = SMLSIZE },
    },
    fields = {
        { x = 41, y = 24, min = 0, max = 16000, to = SMLSIZE, vals = { 14, 15 } },
        { x = 41, y = 34, min = 0, max = 16000, to = SMLSIZE, vals = { 16, 17 } },
        { x = 86, y = 24, min = 0, max = 16000, to = SMLSIZE, vals = { 10, 11 } },
        { x = 86, y = 34, min = 0, max = 16000, to = SMLSIZE, vals = { 12, 13 } },
        { x = 86, y = 44, min = 0, max = 2,     to = SMLSIZE, vals = { 18 }, table = { [0] = "PT1", [1] = "BIQUAD", [2] = "FIR" } },
    }
}
