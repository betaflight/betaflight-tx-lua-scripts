
return {
   read           = 112, -- MSP_PID
   write          = 202, -- MSP_SET_PID
   title          = "PIDs",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 8,
   text = {
      { t = "P",      x =  70,  y = 14, to = SMLSIZE },
      { t = "I",      x =  98,  y = 14, to = SMLSIZE },
      { t = "D",      x = 126,  y = 14, to = SMLSIZE },
      { t = "ROLL",   x =  25,  y = 26, to = SMLSIZE },
      { t = "PITCH",  x =  25,  y = 36, to = SMLSIZE },
      { t = "YAW",    x =  25,  y = 46, to = SMLSIZE },
   },
   fields = {
      -- P
      { x =  66, y = 26, min = 0, max = 200, vals = { 1 }, to = SMLSIZE },
      { x =  66, y = 36, min = 0, max = 200, vals = { 4 }, to = SMLSIZE },
      { x =  66, y = 46, min = 0, max = 200, vals = { 7 }, to = SMLSIZE },
      -- I
      { x =  94, y = 26, min = 0, max = 200, vals = { 2 }, to = SMLSIZE },
      { x =  94, y = 36, min = 0, max = 200, vals = { 5 }, to = SMLSIZE },
      { x =  94, y = 46, min = 0, max = 200, vals = { 8 }, to = SMLSIZE },
      -- D
      { x = 122, y = 26, min = 0, max = 200, vals = { 3 }, to = SMLSIZE },
      { x = 122, y = 36, min = 0, max = 200, vals = { 6 }, to = SMLSIZE },
      --{ x = 122, y = 46, i =  9 },
   },
}