
return {
    read           = 94, -- MSP_PID_ADVANCED
    write          = 95, -- MSP_SET_PID_ADVANCED
    title          = "PIDs (2/2)",
    reboot         = false,
    eepromWrite    = true,
    minBytes       = 44,
    text = {
        { t = "Feed",        x = 97,  y = 52 },
        { t = "forward",     x = 82,  y = 70 },
        { t = "D",           x = 207, y = 52 },
        { t = "Min",         x = 202, y = 70 },
        { t = "ROLL",        x = 28,  y = 100 },
        { t = "PITCH",       x = 28,  y = 150 },
        { t = "YAW",         x = 28,  y = 200 },

        { t = "Feedforward", x = 28, y = 250 },
        { t = "Transition",  x = 40, y = 270, to = SMLSIZE },
        { t = "D Min",       x = 28, y = 300 },
        { t = "Gain",        x = 40, y = 320, to = SMLSIZE },
        { t = "Advance",     x = 40, y = 350, to = SMLSIZE },
    },
    fields = {
        -- ROLL FF
        { x = 102, y = 100, min = 0, max = 2000, vals = { 33, 34 }, to = MIDSIZE },
        -- PITCH FF
        { x = 102, y = 150, min = 0, max = 2000, vals = { 35, 36 }, to = MIDSIZE },
        -- YAW FF
        { x = 102, y = 200, min = 0, max = 2000, vals = { 37, 38 }, to = MIDSIZE },
        -- ROLL D MIN
        { x = 202, y = 100, min = 0, max = 100,  vals = { 40 },     to = MIDSIZE },
        -- PITCH D MIN
        { x = 202, y = 150, min = 0, max = 100,  vals = { 41 },     to = MIDSIZE },
        -- YAW D MIN
        { x = 202, y = 200, min = 0, max = 100,  vals = { 42 },     to = MIDSIZE },
        -- FF TRANSITION
        { x = 150, y = 270, min = 0, max = 100,  vals = { 9 }, scale = 100 },
        -- D MIN GAIN
        { x = 150, y = 320, min = 0, max = 100,  vals = { 43 } },
        -- D MIN ADVANCE
        { x = 150, y = 350, min = 0, max = 200,  vals = { 44 } },
    },
}
