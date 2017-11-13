
return {
   read           = 94, -- MSP_PID_ADVANCED
   write          = 95, -- MSP_SET_PID_ADVANCED
   title          = "Rates (2/2)",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 23,
   text = {
      { t = "Anti-Gravity",       x =  35, y =  68, to = NORMSIZE },
      { t = "Gain",               x =  35, y = 115, to = SMLSIZE },
      { t = "Threshold",          x =  35, y = 155, to = SMLSIZE },
      { t = "Dterm Setpoint",     x = 240, y = 68,  to = NORMSIZE },
      { t = "Weight",             x = 240, y = 115, to = SMLSIZE },
      { t = "Transition",         x = 240, y = 155, to = SMLSIZE },
      { t = "VBAT Compensation",  x =  35, y = 200, to = SMLSIZE }
   },
   fields = {
      --  GAIN
      { x = 129, y =  100, min = 1000, max = 30000, vals = { 22, 23 }, scale = 1000, mult = 1000, to = DBLSIZE },
      --  THRESHOLD
      { x = 129, y = 140, min = 20, max = 1000, vals = { 20, 21 }, to = DBLSIZE },
      --  WEIGHT
      { x = 340, y =  100, min = 0, max = 254, vals = { 10 }, scale = 100, to = DBLSIZE },
      --  TRANSITION
      { x = 340, y = 140, min = 0, max = 100, vals = { 9 }, scale = 100, to = DBLSIZE },
      --  VBAT COMPENSATION
      { x = 240, y = 185, min = 0, max = 1, vals = { 8 }, table = { [0]="OFF", "ON" }, to = DBLSIZE },
   }
}
