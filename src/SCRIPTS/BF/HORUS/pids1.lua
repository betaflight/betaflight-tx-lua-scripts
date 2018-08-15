
return {
   read           = 112, -- MSP_PID
   write          = 202, -- MSP_SET_PID
   title          = "PIDs (1/2)",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 8,
   text = {
      { t = "P",      x = 142,  y =  48, to = MIDSIZE },
      { t = "I",      x = 244,  y =  48, to = MIDSIZE },
      { t = "D",      x = 342,  y =  48, to = MIDSIZE },
      { t = "ROLL",   x =  28,  y = 100 },
      { t = "PITCH",  x =  28,  y = 150 },
      { t = "YAW",    x =  28,  y = 200 },
   },
   fields = {
      -- P
      { x = 140, y = 100, min = 0, max = 200, vals = { 1 }, to = MIDSIZE },
      { x = 140, y = 150, min = 0, max = 200, vals = { 4 }, to = MIDSIZE },
      { x = 140, y = 200, min = 0, max = 200, vals = { 7 }, to = MIDSIZE },
      -- I
      { x = 240, y = 100, min = 0, max = 200, vals = { 2 }, to = MIDSIZE },
      { x = 240, y = 150, min = 0, max = 200, vals = { 5 }, to = MIDSIZE },
      { x = 240, y = 200, min = 0, max = 200, vals = { 8 }, to = MIDSIZE },
      -- D
      { x = 340, y = 100, min = 0, max = 200, vals = { 3 }, to = MIDSIZE },
      { x = 340, y = 150, min = 0, max = 200, vals = { 6 }, to = MIDSIZE },
   },
}