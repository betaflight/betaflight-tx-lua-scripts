local display = assert(loadScript(radio.templateHome.."pids2.lua"))()
return {
    read            = 94, -- MSP_PID_ADVANCED
    write           = 95, -- MSP_SET_PID_ADVANCED
    title           = "PIDs (2/2)",
    reboot          = false,
    eepromWrite     = true,
    minBytes        = 44,
    yMinLimit       = display.yMinLimit,
    yMaxLimit       = display.yMaxLimit,
    text            = display.text,
    fieldLayout     = display.fieldLayout,
    fields          = {
        { min = 0, max = 2000, vals = { 33, 34 }, },
        { min = 0, max = 2000, vals = { 35, 36 }, },
        { min = 0, max = 2000, vals = { 37, 38 }, },
        { min = 0, max = 100,  vals = { 40 },     },
        { min = 0, max = 100,  vals = { 41 },     },
        { min = 0, max = 100,  vals = { 42 },     },
        { min = 0, max = 100,  vals = { 9 }, scale = 100 },
        { min = 0, max = 100,  vals = { 43 },     },
        { min = 0, max = 200,  vals = { 44 },     },
    },
}
