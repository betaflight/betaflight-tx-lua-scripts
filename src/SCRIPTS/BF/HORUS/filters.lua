
return {
    read              = 92, -- MSP_FILTER_CONFIG
    write             = 93, -- MSP_SET_FILTER_CONFIG
    eepromWrite       = true,
    reboot            = false,
    title             = "Filters",
    minBytes          = 18,
    outputBytes       = 18,
    text= {
        -- Column headers
        { t = "Gy LP",         x = 60,  y = 68, to = SMLSIZE },
        { t = "Gy NF1",        x = 125, y = 68, to = SMLSIZE  },
        { t = "Gy NF2",        x = 190, y = 68, to = SMLSIZE  },
        { t = "DT LP",         x = 255, y = 68, to = SMLSIZE  },
        { t = "DT NF",         x = 315, y = 68, to = SMLSIZE  },
        { t = "Yaw LP",        x = 385, y = 68, to = SMLSIZE  },

        -- Line titles
        { t = "Hz",            x = 48,  y = 110, to = SMLSIZE + RIGHT },
        { t = "COff",          x = 48,  y = 155, to = SMLSIZE + RIGHT },
        
        { t = "DTerm LP Type", x = 60,  y = 208 },
    },
    fields = {
        { x =  60, y = 110, min = 0, max =   255, vals = { 1 },      to = MIDSIZE },

        { x = 125, y = 110, min = 0, max = 16000, vals = { 6, 7 },   to = MIDSIZE },
        { x = 125, y = 155, min = 0, max = 16000, vals = { 8, 9 },   to = MIDSIZE },

        { x = 190, y = 110, min = 0, max = 16000, vals = { 14, 15 }, to = MIDSIZE },
        { x = 190, y = 155, min = 0, max = 16000, vals = { 16, 17 }, to = MIDSIZE },

        { x = 255, y = 110, min = 0, max = 16000, vals = { 2, 3 },   to = MIDSIZE },

        { x = 315, y = 110, min = 0, max = 16000, vals = { 10, 11 }, to = MIDSIZE },
        { x = 315, y = 155, min = 0, max = 16000, vals = { 12, 13 }, to = MIDSIZE },

        { x = 391, y = 110, min = 0, max =   500, vals = { 4, 5 },   to = MIDSIZE },

        { x = 208, y = 208,  min = 0, max = 2,    vals = { 18 },     to = MIDSIZE,
          table = { [0] = "PT1", [1] = "BIQUAD", [2] = "FIR" }
        },
    }
}
