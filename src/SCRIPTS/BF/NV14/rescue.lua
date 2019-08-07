return {
   read           = 135, -- MSP_GPS_RESCUE
   write          = 225, -- MSP_SET_GPS_RESCUE
   title          = "GPS Rescue",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 16,
   requiredVersion = 1.041,
   text = {
      { t = "Min Sats.",        x = 10,  y =  40 },
      { t = "Angle",            x = 10,  y =  80 },
      { t = "Initial Altitude", x = 10,  y = 120 },
      { t = "Descent Distance", x = 10,  y = 160 },
      { t = "Ground Speed",     x = 10,  y = 200 },

      { t = "Snty.",            x =  10, y = 240 },
      { t = "Throttle",         x =  10, y = 280 },
      { t = "Min",              x =  10, y = 320 },
      { t = "Hover",            x =  10, y = 360 },
      { t = "Max",              x =  10, y = 400 },
   },
   fields = {
      { x = 260, y = 40, min =    0, max =  50, vals = { 16  } },
      { x = 260, y = 80, min =    0, max = 200, vals = { 1,2 } },
      { x = 260, y = 120, min =   20, max = 100, vals = { 3,4 } },
      { x = 260, y = 160, min =   30, max = 500, vals = { 5,6 } },
      { x = 260, y = 200, min =   30, max =3000, vals = { 7,8 } },


      { x = 260, y = 240, min =   0,  max = 2   , vals =  { 15    } ,table = { [0]="OFF","ON","FS_ONLY"}},
      { x = 260, y = 320, min = 1000, max = 2000, vals =  {  9,10 }  },
      { x = 260, y = 360, min = 1000, max = 2000, vals =  { 13,14 }  },
      { x = 260, y = 400, min = 1000, max = 2000, vals =  { 11,12 }  },

   },
}
