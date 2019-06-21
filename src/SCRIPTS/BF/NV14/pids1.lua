
return {
    read           = 112, -- MSP_PID
    write          = 202, -- MSP_SET_PID
    title          = "PIDs (1/2)",
    reboot         = false,
    eepromWrite    = true,
    minBytes       = 9,
    text = {
        { t = "P",     x = 100, y = 48, to = MIDSIZE },
        { t = "I",     x = 180, y = 48, to = MIDSIZE },
        { t = "D",     x = 260, y = 48, to = MIDSIZE },
        { t = "ROLL",  x = 10,  y = 100 },
        { t = "PITCH", x = 10,  y = 150 },
        { t = "YAW",   x = 10,  y = 200 },
    },
    fields = {
        -- P
        { x = 100, y = 100, min = 0, max = 200, vals = { 1 }, to = MIDSIZE },
        { x = 100, y = 150, min = 0, max = 200, vals = { 4 }, to = MIDSIZE },
        { x = 100, y = 200, min = 0, max = 200, vals = { 7 }, to = MIDSIZE },
        -- I
        { x = 180, y = 100, min = 0, max = 200, vals = { 2 }, to = MIDSIZE },
        { x = 180, y = 150, min = 0, max = 200, vals = { 5 }, to = MIDSIZE },
        { x = 180, y = 200, min = 0, max = 200, vals = { 8 }, to = MIDSIZE },
        -- D
        { x = 260, y = 100, min = 0, max = 200, vals = { 3 }, to = MIDSIZE },
        { x = 260, y = 150, min = 0, max = 200, vals = { 6 }, to = MIDSIZE },
        { x = 260, y = 200, min = 0, max = 200, vals = { 9 }, to = MIDSIZE },
    },
}
