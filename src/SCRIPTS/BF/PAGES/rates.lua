local display = assert(loadScript(radio.templateHome.."rates.lua"))()
return {
    read              = 111, -- MSP_RC_TUNING
    write             = 204, -- MSP_SET_RC_TUNING
    title             = "Rates",
    reboot            = false,
    eepromWrite       = true,
    minBytes          = 16,
    yMinLimit         = display.yMinLimit,
    yMaxLimit         = display.yMaxLimit,
    text              = display.text,
    fields            = display.fields,
}
