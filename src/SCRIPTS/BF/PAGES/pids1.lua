local display = assert(loadScript(radio.templateHome.."pids1.lua"))()
return {
    read           = 112, -- MSP_PID
    write          = 202, -- MSP_SET_PID
    title          = "PIDs (1/2)",
    reboot         = false,
    eepromWrite    = true,
    minBytes       = 9,
    text = display.text,
    fieldLayout = display.fieldLayout,
    fields = {
        { min = 0, max = 200, vals = { 1 }, },
        { min = 0, max = 200, vals = { 4 }, },
        { min = 0, max = 200, vals = { 7 }, },
        { min = 0, max = 200, vals = { 2 }, },
        { min = 0, max = 200, vals = { 5 }, },
        { min = 0, max = 200, vals = { 8 }, },
        { min = 0, max = 200, vals = { 3 }, },
        { min = 0, max = 200, vals = { 6 }, },
        { min = 0, max = 200, vals = { 9 }, },
    },
}
