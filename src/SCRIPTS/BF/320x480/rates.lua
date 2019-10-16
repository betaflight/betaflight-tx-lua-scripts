return {
    read           = 111, -- MSP_RC_TUNING
    write          = 204, -- MSP_SET_RC_TUNING
    title          = "Rates",
    reboot         = false,
    eepromWrite    = true,
    minBytes       = 16,
    text = {
        { t = "RC",         x = 100, y = 52  },
        { t = "Rate",       x = 94,  y = 70  },
        { t = "Super",      x = 148, y = 52  },
        { t = "Rate",       x = 152, y = 70  },
        { t = "RC",         x = 214, y = 52  },
        { t = "Expo",       x = 207, y = 70  },
        { t = "ROLL",       x = 28,  y = 100 },
        { t = "PITCH",      x = 28,  y = 150 },
        { t = "YAW",        x = 28,  y = 200 },
        
        { t = "Throttle",   x = 28, y = 250 },
        { t = "Mid",        x = 40, y = 270,  to = SMLSIZE },
        { t = "Expo",       x = 40, y = 290, to = SMLSIZE },
        { t = "Limit Type", x = 40, y = 310, to = SMLSIZE },
        { t = "Limit %",    x = 40, y = 330, to = SMLSIZE },
        { t = "TPA",        x = 28, y = 350 },
        { t = "Rate",       x = 40, y = 370, to = SMLSIZE },
        { t = "Breakpoint", x = 40, y = 390, to = SMLSIZE },
    },
    fields = {
        -- RC Rates
        { x = 102, y = 100, vals = { 1 },     min = 0,    max = 255, scale = 100, to = MIDSIZE },
        { x = 102, y = 150, vals = { 13 },    min = 0,    max = 255, scale = 100, to = MIDSIZE },
        { x = 102, y = 200, vals = { 12 },    min = 0,    max = 255, scale = 100, to = MIDSIZE },
        -- Super Rates
        { x = 158, y = 100, vals = { 3 },     min = 0,    max = 100, scale = 100, to = MIDSIZE },
        { x = 158, y = 150, vals = { 4 },     min = 0,    max = 100, scale = 100, to = MIDSIZE },
        { x = 158, y = 200, vals = { 5 },     min = 0,    max = 255, scale = 100, to = MIDSIZE },
        -- RC Expo
        { x = 216, y = 100, vals = { 2 },     min = 0,    max = 100, scale = 100, to = MIDSIZE },
        { x = 216, y = 150, vals = { 14 },    min = 0,    max = 100, scale = 100, to = MIDSIZE },
        { x = 216, y = 200, vals = { 11 },    min = 0,    max = 100, scale = 100, to = MIDSIZE },
        -- Throttle
        { x = 150, y = 270,  vals = { 7 },     min = 0,    max = 100, scale = 100 },
        { x = 150, y = 290, vals = { 8 },     min = 0,    max = 100, scale = 100 },
        { x = 150, y = 310, vals = { 15 },    min = 0,    max = 2, table = { [0] = "OFF", "SCALE", "CLIP" } },
        { x = 150, y = 330, vals = { 16 },    min = 25,   max = 100 },
        -- TPA
        { x = 150, y = 370, vals = { 6 },     min = 0,    max = 100, scale = 100 },
        { x = 150, y = 390, vals = { 9, 10 }, min = 1000, max = 2000 },
    },
}
