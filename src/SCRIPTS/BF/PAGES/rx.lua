local display = assert(loadScript(radio.templateHome.."rx.lua"))()
return {
    read              = 44, -- MSP_RX_CONFIG
    write             = 45, -- MSP_SET_RX_CONFIG
    title             = "RX",
    reboot            = false,
    eepromWrite       = true,
    minBytes       	  = 23,
    yMinLimit         = display.yMinLimit,
    yMaxLimit         = display.yMaxLimit,
    text              = display.text,
    fields            = display.fields,
}
