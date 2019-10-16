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
    fields          = display.fields,
}
