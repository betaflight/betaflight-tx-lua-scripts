
return {
   read           = 94, -- MSP_PID_ADVANCED
   write          = 95, -- MSP_SET_PID_ADVANCED
   title          = "Rates (3/3)",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 23,
   outputBytes    = 23,
   text = {
      { t = "Anti-Grav Gain", x = 15, y = 17, to = SMLSIZE },
      { t = "Anti-Grav Thr",  x = 15, y = 30, to = SMLSIZE },
      { t = "VBAT Compens", x = 15, y = 43, to = SMLSIZE }
   },
   fields = {
      { x = 90,  y = 17, to=SMLSIZE, min = 1000, max = 30000, vals = { 22, 23 }, scale = 1000, mult = 100 },
      { x = 90,  y = 30, to=SMLSIZE, min = 20, max = 1000, vals = { 20, 21 } },
      { x = 90, y = 43, to=SMLSIZE, min = 0, max = 1, vals = { 8 }, table = { [0]="OFF", "ON" } },
   }
}
