
return {
    read              = 92, -- MSP_FILTER_CONFIG
    write             = 93, -- MSP_SET_FILTER_CONFIG
    eepromWrite       = true,
    reboot            = false,
    title             = "Filters",
    minBytes          = 18,
    text= {
        { t = "Gy LP",         x = 60,  y = 104, to = SMLSIZE },
        { t = "Hz",            x = 15,  y = 160, to = SMLSIZE },
        { t = "COff",          x = 15,  y = 210, to = SMLSIZE },
        { t = "Yaw LP",        x = 385, y = 104, to = SMLSIZE },
        { t = "Gy NF1",        x = 125, y = 104, to = SMLSIZE },
        { t = "Gy NF2",        x = 190, y = 104, to = SMLSIZE },
        { t = "DT LP",         x = 255, y = 104, to = SMLSIZE },
        { t = "DT NF",         x = 315, y = 104, to = SMLSIZE },
        { t = "DTerm LP Type", x = 60,  y = 55,  to = SMLSIZE },
    },
    fields = {
        { x = 60,   y = 150, min = 0, max = 255,   to = MIDSIZE, vals = { 1 } },
        { x = 255,  y = 150, min = 0, max = 16000, to = MIDSIZE, vals = { 2, 3 } },
        { x = 391,  y = 150, min = 0, max = 500,   to = MIDSIZE, vals = { 4, 5 } },
        { x = 125,  y = 150, min = 0, max = 16000, to = MIDSIZE, vals = { 6, 7 } },
        { x = 125,  y = 200, min = 0, max = 16000, to = MIDSIZE, vals = { 8, 9 } },
        { x = 190,  y = 150, min = 0, max = 16000, to = MIDSIZE, vals = { 14, 15 } },
        { x = 190,  y = 200, min = 0, max = 16000, to = MIDSIZE, vals = { 16, 17 } },
        { x = 315,  y = 150, min = 0, max = 16000, to = MIDSIZE, vals = { 10, 11 } },
        { x = 315,  y = 200, min = 0, max = 16000, to = MIDSIZE, vals = { 12, 13 } },
        { x = 190,  y = 45,  min = 0, max = 2,     to = MIDSIZE, vals = { 18 }, table = { [0] = "PT1", [1] = "BIQUAD", [2] = "FIR" } },
    }
}
