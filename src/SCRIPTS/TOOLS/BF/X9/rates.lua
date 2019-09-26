return {
    read           = 111, -- MSP_RC_TUNING
    write          = 204, -- MSP_SET_RC_TUNING
    title          = "Rates",
    reboot         = false,
    eepromWrite    = true,
    minBytes       = 16,
    yMinLimit      = 11,
    yMaxLimit      = 52,
    text = {
        { t = "RC",         x = 43,  y = 11, to = SMLSIZE },
        { t = "Rate",       x = 38,  y = 18, to = SMLSIZE },
        { t = "Super",      x = 63,  y = 11, to = SMLSIZE },
        { t = "Rate",       x = 66,  y = 18, to = SMLSIZE },
        { t = "RC",         x = 99,  y = 11, to = SMLSIZE },
        { t = "Expo",       x = 94,  y = 18, to = SMLSIZE },
        { t = "ROLL",       x = 8,   y = 26, to = SMLSIZE },
        { t = "PITCH",      x = 8,   y = 36, to = SMLSIZE },
        { t = "YAW",        x = 8,   y = 46, to = SMLSIZE },

        { t = "Throttle",   x = 120, y = 12, to = SMLSIZE },
        { t = "Mid",        x = 130, y = 20, to = SMLSIZE },
        { t = "Expo",       x = 130, y = 28, to = SMLSIZE },
        { t = "Limit Type", x = 130, y = 36, to = SMLSIZE },
        { t = "Limit %",    x = 130, y = 44, to = SMLSIZE },
        { t = "TPA",        x = 120, y = 52, to = SMLSIZE },
        { t = "Rate",       x = 130, y = 60, to = SMLSIZE },
        { t = "Breakpoint", x = 130, y = 68, to = SMLSIZE },
    },
    fields = {
        -- RC Rates
        { x = 39,  y = 26, vals = { 1 },     min = 0,    max = 255, scale = 100, to = SMLSIZE },
        { x = 39,  y = 36, vals = { 13 },    min = 0,    max = 255, scale = 100, to = SMLSIZE },
        { x = 39,  y = 46, vals = { 12 },    min = 0,    max = 255, scale = 100, to = SMLSIZE },
        -- Super Rates
        { x = 66,  y = 26, vals = { 3 },     min = 0,    max = 100, scale = 100, to = SMLSIZE },
        { x = 66,  y = 36, vals = { 4 },     min = 0,    max = 100, scale = 100, to = SMLSIZE },
        { x = 66,  y = 46, vals = { 5 },     min = 0,    max = 255, scale = 100, to = SMLSIZE },
        -- RC Expo
        { x = 94,  y = 26, vals = { 2 },     min = 0,    max = 100, scale = 100, to = SMLSIZE },
        { x = 94,  y = 36, vals = { 14 },    min = 0,    max = 100, scale = 100, to = SMLSIZE },
        { x = 94,  y = 46, vals = { 11 },    min = 0,    max = 100, scale = 100, to = SMLSIZE },
        -- Throttle
        { x = 180, y = 20, vals = { 7 },     min = 0,    max = 100, scale = 100, to = SMLSIZE },
        { x = 180, y = 28, vals = { 8 },     min = 0,    max = 100, scale = 100, to = SMLSIZE },
        { x = 180, y = 36, vals = { 15 },    min = 0,    max = 2,   to = SMLSIZE, table = { [0] = "OFF", "SCALE", "CLIP" } },
        { x = 180, y = 44, vals = { 16 },    min = 25,   max = 100, to = SMLSIZE },
        -- TPA
        { x = 180, y = 60, vals = { 6 } ,    min = 0,    max = 100, scale = 100, to = SMLSIZE },
        { x = 180, y = 68, vals = { 9, 10 }, min = 1000, max = 2000, to = SMLSIZE },
    },
}
