
return {
   read           = 94, -- MSP_PID_ADVANCED
   write          = 95, -- MSP_SET_PID_ADVANCED
   title          = "Rates (2/2)",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 23,
   outputBytes    = 23,
   text = {
      { t = "Anti-Gravity Gain",      x = 40, y = 17, to = SMLSIZE },
      { t = "Anti-Gravity Threshold", x = 40, y = 30, to = SMLSIZE },
      { t = "VBAT Compensation",      x = 40, y = 43, to = SMLSIZE }
   },
   fields = {
      { x = 155, y = 17, min = 1000, max = 30000, vals = { 22, 23 }, to = SMLSIZE, scale = 1000, mult = 100 },
      { x = 155, y = 30, min = 20,   max = 1000,  vals = { 20, 21 }, to = SMLSIZE },
      { x = 155, y = 43, min = 0,    max = 1,     vals = { 8 },      to = SMLSIZE, table = { [0]="OFF", "ON" } },
   }
}
