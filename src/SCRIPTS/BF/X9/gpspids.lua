return {
   read           = 136, -- MSP_GPS_RESCUE_PIDS
   write          = 226, -- MSP_SET_GPS_RESCUE_PIDS
   title          = "GPS Rescue / PIDs",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 14,
   text = {
      { t = "P",        x =  70,  y = 14, to = SMLSIZE },
      { t = "I",        x =  98,  y = 14, to = SMLSIZE },
      { t = "D",        x = 126,  y = 14, to = SMLSIZE },
      { t = "Throttle", x =  25,  y = 26, to = SMLSIZE },
      { t = "Velocity", x =  25,  y = 36, to = SMLSIZE },
      { t = "Yaw",      x =  25,  y = 46, to = SMLSIZE },	  
   },
   fields = {
      -- P
      { x =  66, y = 26, min = 0, max = 500, vals = { 1,2 }, to = SMLSIZE },
      { x =  66, y = 36, min = 0, max = 500, vals = { 7,8 }, to = SMLSIZE },
      { x =  66, y = 46, min = 0, max = 500, vals = {13,14}, to = SMLSIZE },	  
      -- I
      { x =  94, y = 26, min = 0, max = 500, vals = { 3,4 }, to = SMLSIZE },
      { x =  94, y = 36, min = 0, max = 500, vals = { 9,10 }, to = SMLSIZE },
      -- D
      { x = 122, y = 26, min = 0, max = 500, vals = { 5,6 }, to = SMLSIZE },
      { x = 122, y = 36, min = 0, max = 500, vals = { 11,12 }, to = SMLSIZE },

   },
}