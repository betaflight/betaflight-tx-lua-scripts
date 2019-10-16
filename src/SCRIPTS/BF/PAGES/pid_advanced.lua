local display = assert(loadScript(radio.templateHome.."pid_advanced.lua"))()
return {
    read            = 94, -- MSP_PID_ADVANCED
    write           = 95, -- MSP_SET_PID_ADVANCED
    title           = "PID Advanced",
    reboot          = false,
    eepromWrite     = true,
    minBytes        = 46,
    outputBytes     = 46,
    yMinLimit       = display.yMinLimit,
    yMaxLimit       = display.yMaxLimit,
    text            = display.text,
    fields          = display.fields,
}