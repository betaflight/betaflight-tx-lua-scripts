return {
   read           = 111, -- MSP_RC_TUNING
   write          = 204, -- MSP_SET_RC_TUNING
   title          = "Rates (1/3)",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 12,
   text = {
      { t = "RC",       x = 43,  y = 11, to = SMLSIZE },
      { t = "Rate",     x = 38,  y = 18, to = SMLSIZE },
      { t = "Super",    x = 63,  y = 11, to = SMLSIZE },
      { t = "Rate",     x = 66,  y = 18, to = SMLSIZE },
      { t = "RC",       x = 99,  y = 11, to = SMLSIZE },
      { t = "Expo",     x = 94,  y = 18, to = SMLSIZE },
      { t = "ROLL",     x = 10,   y = 26, to = SMLSIZE },
      { t = "PITCH",    x = 10,   y = 36, to = SMLSIZE },
      { t = "YAW",      x = 10,   y = 46, to = SMLSIZE },
   },
   fields = {
      -- RC Rates
      { x = 39,   y = 26, to=SMLSIZE,  vals = { 1 },  min = 0, max = 255, scale = 100 }, 
      { x = 39,   y = 36, to=SMLSIZE,  vals = { 13 },  min = 0, max = 255, scale = 100 }, 
      { x = 39,   y = 46, to=SMLSIZE,  vals = { 12 }, min = 0, max = 255, scale = 100 },
      -- Super Rates
      { x = 66,   y = 26, to=SMLSIZE,  vals = { 3 },  min = 0, max = 100, scale = 100 },
      { x = 66,   y = 36, to=SMLSIZE,  vals = { 4 },  min = 0, max = 100, scale = 100 },
      { x = 66,   y = 46, to=SMLSIZE,  vals = { 5 },  min = 0, max = 255, scale = 100 },
      -- RC Expo
      { x = 94,   y = 26, to=SMLSIZE,  vals = { 2 },  min = 0, max = 100, scale = 100 },
      { x = 94,   y = 36, to=SMLSIZE,  vals = { 14 },  min = 0, max = 100, scale = 100 },
      { x = 94,   y = 46, to=SMLSIZE,  vals = { 11 }, min = 0, max = 100, scale = 100 }                 
   },
}