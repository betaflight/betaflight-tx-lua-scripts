
return {
   read           = 112, -- MSP_PID
   write          = 202, -- MSP_SET_PID
   title          = "PIDs",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 8,
   text = {
      { t = "P",      x = 140,  y =  48 },
      { t = "I",      x = 240,  y =  48 },
      { t = "D",      x = 340,  y =  48 },
      { t = "ROLL",   x =  35,  y = 100 },
      { t = "PITCH",  x =  35,  y = 150 },
      { t = "YAW",    x =  35,  y = 195 },
   },
   fields = {
      -- P
      { x = 140, y =  85, min = 0, max = 200, vals = { 1 }, to = DBLSIZE  },
      { x = 140, y = 135, min = 0, max = 200, vals = { 4 }, to = DBLSIZE  },
      { x = 140, y = 185, min = 0, max = 200, vals = { 7 }, to = DBLSIZE  },
      -- I
      { x = 240, y =  85, min = 0, max = 200, vals = { 2 }, to = DBLSIZE  },
      { x = 240, y = 135, min = 0, max = 200, vals = { 5 }, to = DBLSIZE  },
      { x = 240, y = 185, min = 0, max = 200, vals = { 8 }, to = DBLSIZE  },
      -- D
      { x = 340, y =  85, min = 0, max = 200, vals = { 3 }, to = DBLSIZE  },
      { x = 340, y = 135, min = 0, max = 200, vals = { 6 }, to = DBLSIZE  },
    --{ x = 340, y = 185, i =  9 },
   },
}
