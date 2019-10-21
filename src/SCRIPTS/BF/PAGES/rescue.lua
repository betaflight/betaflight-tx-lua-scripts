local display = assert(loadScript(radio.templateHome.."rescue.lua"))()
return {
   read              = 135, -- MSP_GPS_RESCUE
   write             = 225, -- MSP_SET_GPS_RESCUE
   title             = "GPS Rescue",
   reboot            = false,
   eepromWrite       = true,
   minBytes          = 16,
   requiredVersion   = 1.041,
   labels            = display.labels,
   fieldLayout       = display.fieldLayout,
   fields            = {
      { min =    0, max =   50, vals = { 16  }, },
      { min =    0, max =  200, vals = { 1,2 }, },
      { min =   20, max =  100, vals = { 3,4 }, },
      { min =   30, max =  500, vals = { 5,6 }, },
      { min =   30, max = 3000, vals = { 7,8 }, },
      { min =   0,  max =    2, vals = { 15 }, table = { [0]="OFF","ON","FS_ONLY"}, },
      { min = 1000, max = 2000, vals = { 9,10 }, },
      { min = 1000, max = 2000, vals = { 13,14 }, },
      { min = 1000, max = 2000, vals = { 11,12 }, },
   },
}
