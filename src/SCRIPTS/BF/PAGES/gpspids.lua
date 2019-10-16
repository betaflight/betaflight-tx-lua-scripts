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
    fieldLayout      = display.fieldLayout,
    fields           = {
        { min = 0, max = 200, vals = { 1,2 },   },
        { min = 0, max = 200, vals = { 7,8 },   },
        { min = 0, max = 500, vals = { 13,14 }, },
        { min = 0, max = 200, vals = { 3,4 },   },
        { min = 0, max = 200, vals = { 9,10 },  },
        { min = 0, max = 200, vals = { 5,6 },   },
        { min = 0, max = 200, vals = { 11,12 }, },
     },
}