return {
   read           = 111, -- MSP_RC_TUNING
   write          = 204, -- MSP_SET_RC_TUNING
   title          = "Rates (1/2)",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 12,
   text = {
      { t = "RC",       x = 100, y = 52  },
      { t = "Rate",     x = 94,  y = 70  },
      { t = "Super",    x = 148, y = 52  },
      { t = "Rate",     x = 152, y = 70  },
      { t = "RC",       x = 214, y = 52  },
      { t = "Expo",     x = 207, y = 70  },
      { t = "Throttle", x = 288, y = 68  },
      { t = "Mid",      x = 288, y = 100 },
      { t = "Exp",      x = 288, y = 150 },
      { t = "TPA",      x = 374, y = 68  },
      { t = "Thr",      x = 374, y = 100 },
      { t = "Brk",      x = 374, y = 150 },
      { t = "ROLL",     x = 28,  y = 100 },
      { t = "PITCH",    x = 28,  y = 150 },
      { t = "YAW",      x = 28,  y = 200 },
   },
   fields = {
      -- RC Rates
      { x = 102,  y = 125,  vals = { 1 },  min = 0, max = 255, scale = 100, to=MIDSIZE },
      { x = 102,  y = 150,  vals = { 13 }, min = 0, max = 255, scale = 100, to=MIDSIZE },
      { x = 102,  y = 200,  vals = { 12 }, min = 0, max = 255, scale = 100, to=MIDSIZE },
      -- Super Rates
      { x = 158,  y = 100,  vals = { 3 },  min = 0, max = 100, scale = 100, to=MIDSIZE },
      { x = 158,  y = 150,  vals = { 4 },  min = 0, max = 100, scale = 100, to=MIDSIZE },
      { x = 158,  y = 200,  vals = { 5 },  min = 0, max = 255, scale = 100, to=MIDSIZE },
      -- RC Expo
      { x = 216,  y = 125,  vals = { 2 },  min = 0, max = 100, scale = 100, to=MIDSIZE },
      { x = 216,  y = 150,  vals = { 14 }, min = 0, max = 100, scale = 100, to=MIDSIZE },
      { x = 216,  y = 200,  vals = { 11 }, min = 0, max = 100, scale = 100, to=MIDSIZE },
      -- Throttle
      { x = 330,  y = 100,  vals = { 7 },  min = 0, max = 100, scale = 100, to=MIDSIZE },
      { x = 330,  y = 150,  vals = { 8 },  min = 0, max = 100, scale = 100, to=MIDSIZE },
      -- TPA
      { x = 416,  y = 100,  vals = { 6 } , min = 0, max = 100, scale = 100, to=MIDSIZE },
      { x = 416,  y = 150,  vals = { 9, 10 }, min = 1000, max = 2000,       to=MIDSIZE }
   },
}