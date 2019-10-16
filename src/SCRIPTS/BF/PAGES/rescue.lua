local display = assert(loadScript(radio.templateHome.."rescue.lua"))()
return {
   read              = 135, -- MSP_GPS_RESCUE
   write             = 225, -- MSP_SET_GPS_RESCUE
   title             = "GPS Rescue",
   reboot            = false,
   eepromWrite       = true,
   minBytes          = 16,
   requiredVersion   = 1.041,
   yMinLimit         = display.yMinLimit,
   yMaxLimit         = display.yMaxLimit,
   text              = display.text,
   fields            = display.fields,
}
