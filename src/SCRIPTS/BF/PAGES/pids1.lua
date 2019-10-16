local display = assert(loadScript(radio.templateHome.."pids1.lua"))()
return {
    read           = 112, -- MSP_PID
    write          = 202, -- MSP_SET_PID
    title          = "PIDs (1/2)",
    reboot         = false,
    eepromWrite    = true,
    minBytes       = 9,
    text = display.text,
    fields = display.fields,
}
