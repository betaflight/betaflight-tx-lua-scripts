return {
   read           = 111, -- MSP_RC_TUNING
   write          = 204, -- MSP_SET_RC_TUNING
   title          = "Rates (2/3)",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 12,
   text = {
      { t = "Throttle", x = 26, y = 15, to = SMLSIZE },
      { t = "Mid",      x = 26, y = 28, to = SMLSIZE },
      { t = "Exp",      x = 26, y = 43, to = SMLSIZE },
      { t = "TPA",      x = 86, y = 15, to = SMLSIZE },
      { t = "Thr",      x = 68, y = 28, to = SMLSIZE },
      { t = "Brk",      x = 68, y = 43, to = SMLSIZE },         
   },
   fields = {
      { x = 44,  y = 28, to=SMLSIZE,  vals = { 7 },  min = 0, max = 100, scale = 100 },
      { x = 44,  y = 43, to=SMLSIZE,  vals = { 8 },  min = 0, max = 100, scale = 100 },  
      { x = 86,  y = 28, to=SMLSIZE,  vals = { 6 } , min = 0, max = 100, scale = 100 },
      { x = 86,  y = 43, to=SMLSIZE,  vals = { 9, 10 }, min = 1000, max = 2000 },                  
   },
}