return {
   read           = 135, -- MSP_GPS_RESCUE
   write          = 225, -- MSP_SET_GPS_RESCUE
   title          = "GPS Rescue",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 18,
   
 
   text = {
      { t = "Min Sats.",      x = 30,  y = 16, to = SMLSIZE },
      { t = "Angle",          x = 45,  y = 26, to = SMLSIZE },
      { t = "Initial Alt.",   x = 18,  y = 36, to = SMLSIZE },
      { t = "Descent Dist.",  x = 10,  y = 46, to = SMLSIZE },
      { t = "Ground Speed",   x = 10,  y = 56, to = SMLSIZE },

	  
      { t = "Sanity Ch.",     x =  125,   y = 16, to = SMLSIZE },   
      { t = "Throttle",       x =  125,   y = 26, to = SMLSIZE },      
	  { t = "Min",            x =  128,   y = 36, to = SMLSIZE },
      { t = "Hover",          x =  120,   y = 46, to = SMLSIZE },
	  { t = "Max",            x =  128,   y = 56, to = SMLSIZE },
   },
   fields = {
   
      { x = 75, y = 16, min =    0, max =    50, vals = { 18    }, to = SMLSIZE },	  
      { x = 75, y = 26, min =    0, max =   200, vals = { 1 , 2 }, to = SMLSIZE },
      { x = 75, y = 36, min =   20, max =   100, vals = { 3 , 4 }, to = SMLSIZE },
      { x = 75, y = 46, min =   30, max =   500, vals = { 5 , 6 }, to = SMLSIZE },
      { x = 75, y = 56, min =   30, max =  3000, vals = { 13,14 }, to = SMLSIZE },

      { x = 180, y = 16, min =   0,  max = 2   , vals = { 17    }, to = SMLSIZE,table = { [0]="OFF","ON","FS_ONLY"}},	  
      { x = 150, y = 36, min = 1000, max = 2000, vals = {  7, 8 }, to = SMLSIZE },
      { x = 150, y = 46, min = 1000, max = 2000, vals = {  9,10 }, to = SMLSIZE },	  
      { x = 150, y = 56, min = 1000, max = 2000, vals = { 11,12 }, to = SMLSIZE },
	  
   },
}