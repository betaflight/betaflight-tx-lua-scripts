
return {
   read           = 134, -- MSP_ESC_SENSOR_DATA
   title          = "ESCs",
   minBytes       = 13,
   text = {
      { t = "RPM",   x =  58,  y = 14, to=SMLSIZE },
      { t = "T",  x =  63,  y = 24, to=SMLSIZE },
      { t = "RPM",   x =  57,  y = 36, to=SMLSIZE },
      { t = "T",  x =  63,  y = 46, to=SMLSIZE },
      { t = "4",   x =  10,  y = 19, to=SMLSIZE },
      { t = "3",  x =  10,  y = 41, to=SMLSIZE },
      { t = "2",   x =  114,  y = 19, to=SMLSIZE },
      { t = "1",  x =  114,  y = 41, to=SMLSIZE },
   },
   fields = {
      -- 1
      { x =  27, y = 14, vals = { 12, 13 }, to=SMLSIZE },
      { x =  27, y = 24, vals = { 11 }, to=SMLSIZE },
	  -- 2
      { x =  27, y = 36, vals = { 9, 10 }, to=SMLSIZE },
      { x =  27, y = 46, vals = { 8 }, to=SMLSIZE },
	  -- 3
      { x =  87, y = 14, vals = { 6, 7 }, to=SMLSIZE },
      { x =  87, y = 24, vals = { 5 }, to=SMLSIZE },
      -- 4
      { x = 87, y = 36, vals = { 3, 4 }, to=SMLSIZE },
      { x = 87, y = 46, vals = { 2 }, to=SMLSIZE },
   },
}