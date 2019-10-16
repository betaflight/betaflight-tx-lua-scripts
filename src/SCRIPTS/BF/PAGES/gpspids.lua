local display = assert(loadScript(radio.templateHome.."gpspids.lua"))()
return {
    read             = 136, -- MSP_GPS_RESCUE_PIDS
    write            = 226, -- MSP_SET_GPS_RESCUE_PIDS
    title            = "GPS Rescue / PIDs",
    reboot           = false,
    eepromWrite      = true,
    minBytes         = 14,
    requiredVersion  = 1.041,
    yMinLimit        = display.yMinLimit,
    yMaxLimit        = display.yMaxLimit,
    text             = display.text,
    fields           = display.fields,
}