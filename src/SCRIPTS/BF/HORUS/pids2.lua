
return {
   read           = 94, -- MSP_PID_ADVANCED
   write          = 95, -- MSP_SET_PID_ADVANCED
   title          = "PIDs (2/2)",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 38,
   text = {
      { t = "Feed",       x =  135,  y = 52 },
      { t = "forward",    x =  120,  y = 70 },
      { t = "Transition", x =  250,  y = 150 },
      { t = "ROLL",       x =  28,   y = 100 },
      { t = "PITCH",      x =  28,   y = 150 },
      { t = "YAW",        x =  28,   y = 200 },
   },
   fields = {
      --   ROLL FF
      { x =  140, y = 100, min = 0, max = 200, vals = { 33, 34 }, to = MIDSIZE },
      --   PITCH FF
      { x =  140, y = 150, min = 0, max = 200, vals = { 35, 36 }, to = MIDSIZE },
      --   YAW FF
      { x =  140, y = 200, min = 0, max = 200, vals = { 37, 38 }, to = MIDSIZE },
      --   TRANSITION
      { x =  350, y = 150, min = 0, max = 100, vals = { 9 },      to = MIDSIZE, scale = 100 },
   },
}