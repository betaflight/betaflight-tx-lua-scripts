return {
   read           = 135, -- MSP_GPS_RESCUE
   write          = 225, -- MSP_SET_GPS_RESCUE
   title          = "GPS Rescue",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 18,
   text = {
      { t = "Min Sats.",        x =130,  y =  40, to = MIDSIZE },
      { t = "Angle",            x =150,  y =  80, to = MIDSIZE },
      { t = "Initial Altitude", x = 60,  y = 120, to = MIDSIZE },
      { t = "Descent Distance", x = 10,  y = 160, to = MIDSIZE },
      { t = "Ground Speed",     x = 50,  y = 200, to = MIDSIZE },

      { t = "Snty.",            x =  310,   y =  40, to = MIDSIZE },
      { t = "Throttle",         x =  350,   y =  80, to = MIDSIZE },
      { t = "Min",              x =  330,   y = 120, to = MIDSIZE },
      { t = "Hover",            x =  310,   y = 160, to = MIDSIZE },
      { t = "Max",              x =  330,   y = 200, to = MIDSIZE },
   },
   fields = {
      { x = 260, y =  40, min =    0, max =  50, vals = { 18  }, to = MIDSIZE },
      { x = 260, y =  80, min =    0, max = 200, vals = { 1,2 }, to = MIDSIZE },
      { x = 260, y = 120, min =   20, max = 100, vals = { 3,4 }, to = MIDSIZE },
      { x = 260, y = 160, min =   30, max = 500, vals = { 5,6 }, to = MIDSIZE },
      { x = 260, y = 200, min =   30, max =3000, vals = { 7,8 }, to = MIDSIZE },


      { x = 400, y =  40, min =   0,  max = 2   , vals =  { 17    }, to = MIDSIZE,table = { [0]="OFF","ON","FS_ONLY"}},
      { x = 400, y = 120, min = 1000, max = 2000, vals =  {  9,10 }, to = MIDSIZE },
      { x = 400, y = 160, min = 1000, max = 2000, vals =  { 13,14 }, to = MIDSIZE },
      { x = 400, y = 200, min = 1000, max = 2000, vals =  { 11,12 }, to = MIDSIZE },

   },
}