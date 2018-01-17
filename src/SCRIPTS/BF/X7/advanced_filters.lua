
return {
   read           = 225, -- MSP_ADVANCED_FILTER_CONFIG
   write          = 226, -- MSP_SET_ADVANCED_FILTER_CONFIG
   title          = "Advanced Filters",
   reboot         = true,
   eepromWrite    = true,
   minBytes       = 6,
   text = {
      { t = " Gyro filter Q", x = 30, y = 17, to = SMLSIZE },
      { t = " Gyro filter R", x = 30, y = 30, to = SMLSIZE },
      { t = " Gyro filter P", x = 30, y = 43, to = SMLSIZE },
   },
   fields = {
      { x = 100,  y = 17, to=SMLSIZE, min = 0, max = 16000, vals = { 1, 2 }, mult = 100 },
      { x = 100,  y = 30, to=SMLSIZE, min = 0, max = 16000, vals = { 3, 4 }, mult = 1 },
      { x = 100,  y = 43, to=SMLSIZE, min = 0, max = 16000, vals = { 5, 6 }, mult = 100 },
   },
}
