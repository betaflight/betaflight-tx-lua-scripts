
return {
   read           = 94, -- MSP_PID_ADVANCED
   write          = 95, -- MSP_SET_PID_ADVANCED
   title          = "Rates (2/2)",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 23,
   text = {
      { t = "Anti-Gravity",       x =  28, y =  62 },
      { t = "Gain",               x =  38, y = 100 },
      { t = "Threshold",          x =  38, y = 142 },
      { t = "Dterm Setpoint",     x = 232, y =  62 },
      { t = "Weight",             x = 242, y = 100 },
      { t = "Transition",         x = 242, y = 142 },
      { t = "VBAT Compensation",  x =  28, y = 200 }
   },
   fields = {
      --  GAIN
      { x = 144, y = 100, min = 1000, max = 30000, vals = { 22, 23 }, to = MIDSIZE, scale = 1000, mult = 100 },
      --  THRESHOLD
      { x = 144, y = 142, min = 20,   max = 1000,  vals = { 20, 21 }, to = MIDSIZE },
      --  WEIGHT
      { x = 348, y = 100, min = 0,    max = 254,   vals = { 10 },     to = MIDSIZE, scale = 100 },
      --  TRANSITION
      { x = 348, y = 142, min = 0,    max = 100,   vals = { 9 },      to = MIDSIZE, scale = 100 },
      --  VBAT COMPENSATION
      { x = 236, y = 200, min = 0,    max = 1,     vals = { 8 },      to = MIDSIZE, table = { [0]="OFF", "ON" } },
   }
}
