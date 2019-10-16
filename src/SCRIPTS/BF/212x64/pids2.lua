
return {
    read           = 94, -- MSP_PID_ADVANCED
    write          = 95, -- MSP_SET_PID_ADVANCED
    title          = "PIDs (2/2)",
    reboot         = false,
    eepromWrite    = true,
    minBytes       = 44,
    text = {
        { t = "Feed",        x = 46,  y = 11, to = SMLSIZE },
        { t = "forward",     x = 38,  y = 18, to = SMLSIZE },
        { t = "D",           x = 86,  y = 11, to = SMLSIZE },
        { t = "Min",         x = 81,  y = 18, to = SMLSIZE },
        { t = "ROLL",        x = 8,   y = 26, to = SMLSIZE },
        { t = "PITCH",       x = 8,   y = 36, to = SMLSIZE },
        { t = "YAW",         x = 8,   y = 46, to = SMLSIZE },
        
        { t = "Feedforward", x = 110, y = 14, to = SMLSIZE },
        { t = "Transition",  x = 120, y = 22, to = SMLSIZE },
        { t = "D Min",       x = 110, y = 30, to = SMLSIZE },
        { t = "Gain",        x = 120, y = 38, to = SMLSIZE },
        { t = "Advance",     x = 120, y = 46, to = SMLSIZE },
    },
    fields = {
        -- ROLL FF
        { x = 49,  y = 26, min = 0, max = 2000, vals = { 33, 34 }, to = SMLSIZE },
        -- PITCH FF
        { x = 49,  y = 36, min = 0, max = 2000, vals = { 35, 36 }, to = SMLSIZE },
        -- YAW FF
        { x = 49,  y = 46, min = 0, max = 2000, vals = { 37, 38 }, to = SMLSIZE },
        -- ROLL D MIN
        { x = 81,  y = 26, min = 0, max = 100,  vals = { 40 },     to = SMLSIZE },
        -- PITCH D MIN
        { x = 81,  y = 36, min = 0, max = 100,  vals = { 41 },     to = SMLSIZE },
        -- YAW D MIN
        { x = 81,  y = 46, min = 0, max = 100,  vals = { 42 },     to = SMLSIZE },
        -- FF TRANSITION
        { x = 180, y = 22, min = 0, max = 100,  vals = { 9 },      to = SMLSIZE, scale = 100 },
        -- D MIN GAIN
        { x = 180, y = 38, min = 0, max = 100,  vals = { 43 },     to = SMLSIZE },
        -- D MIN ADVANCE
        { x = 180, y = 46, min = 0, max = 200,  vals = { 44 },     to = SMLSIZE },
    },
}
