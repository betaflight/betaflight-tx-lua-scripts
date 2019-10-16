local display = assert(loadScript(radio.templateHome.."filters.lua"))()
return {
    read              = 92, -- MSP_FILTER_CONFIG
    write             = 93, -- MSP_SET_FILTER_CONFIG
    eepromWrite       = true,
    reboot            = false,
    title             = "Filters",
    minBytes          = 37,
    outputBytes       = 37,
    yMinLimit         = display.yMinLimit,
    yMaxLimit         = display.yMaxLimit,
    text              = display.text,
    fields            = display.fields,
}