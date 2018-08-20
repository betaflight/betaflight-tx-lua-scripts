
return {
   read           = 94, -- MSP_PID_ADVANCED
   write          = 95, -- MSP_SET_PID_ADVANCED
   title          = "PIDs (2/2)",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 38,
   text = {
      { t = "Feed",    x =  45,  y = 11, to=SMLSIZE },
      { t = "forward", x =  37,  y = 18, to=SMLSIZE },
      { t = "Transn",  x =  86,  y = 31, to=SMLSIZE },
      { t = "ROLL",    x =  10,  y = 26, to=SMLSIZE },
      { t = "PITCH",   x =  10,  y = 36, to=SMLSIZE },
      { t = "YAW",     x =  10,  y = 46, to=SMLSIZE },
   },
   fields = {
      --   ROLL FF
      { x =  48, y = 26, min = 0, max = 200, vals = { 33, 34 }, to=SMLSIZE },
      --   PITCH FF
      { x =  48, y = 36, min = 0, max = 200, vals = { 35, 36 }, to=SMLSIZE },
      --   YAW FF
      { x =  48, y = 46, min = 0, max = 200, vals = { 37, 38 }, to=SMLSIZE },
      -- TRANSITION
      { x =  94, y = 40, min = 0, max = 100, vals = { 9 },      to=SMLSIZE, scale = 100 },
   },
}
