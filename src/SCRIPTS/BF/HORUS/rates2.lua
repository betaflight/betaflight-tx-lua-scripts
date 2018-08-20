
return {
   read           = 94, -- MSP_PID_ADVANCED
   write          = 95, -- MSP_SET_PID_ADVANCED
   title          = "Rates (2/2)",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 23,
   outputBytes    = 23,
   text = {
      { t = "Anti-Gravity Gain",      x = 45, y = 68 },
      { t = "Anti-Gravity Threshold", x = 45, y = 110 },
      { t = "VBAT Compensation",      x = 45, y = 155 }
   },
   fields = {
      --  GAIN
      { x = 300, y = 68,  min = 1000, max = 30000, vals = { 22, 23 }, to = MIDSIZE, scale = 1000, mult = 100 },
      --   THRESHOLD
      { x = 300, y = 110, min = 20,   max = 1000,  vals = { 20, 21 }, to = MIDSIZE },
      --   VBAT COMPENSATION
      { x = 300, y = 155, min = 0,    max = 1,     vals = { 8 },      to = MIDSIZE,  table = { [0]="OFF", "ON" } },
   }
}
