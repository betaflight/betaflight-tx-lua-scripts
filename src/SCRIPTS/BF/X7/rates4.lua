
return {
   read           = 94, -- MSP_PID_ADVANCED
   write          = 95, -- MSP_SET_PID_ADVANCED
   title          = "Rates (4/4)",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 23,
   text = {
      { t = "Dterm Setpoint", x = 28, y = 15, to = SMLSIZE },
      { t = "Weight", x = 33, y = 28, to = SMLSIZE },
      { t = "Transn", x = 33, y = 41, to = SMLSIZE },
   },
   fields = {
      { x = 78, y = 28, to=SMLSIZE, min = 0, max = 254, vals = { 10 }, scale = 100 },
      { x = 78, y = 41, to=SMLSIZE, min = 0, max = 100, vals = { 9 }, scale = 100 },
   }
}