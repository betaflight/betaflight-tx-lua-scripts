return {
   text = {
      { t = "P",        x = 100,  y =  48, },
      { t = "I",        x = 180,  y =  48, },
      { t = "D",        x = 260,  y =  48, },
      { t = "Throttle", x =  10,  y = 100, },
      { t = "Velocity", x =  10,  y = 150, },
      { t = "Yaw"     , x =  10,  y = 200, },
   },
   fields = {
      { x = 100, y = 100, min = 0, max = 200, vals = { 1, 3  }, },
      { x = 100, y = 150, min = 0, max = 200, vals = { 7, 8  }, },
      { x = 100, y = 200, min = 0, max = 500, vals = {13,14  }, },
      { x = 180, y = 100, min = 0, max = 200, vals = { 3, 4  }, },
      { x = 180, y = 150, min = 0, max = 200, vals = { 9,10  }, },
      { x = 260, y = 100, min = 0, max = 200, vals = { 5, 6  }, },
      { x = 260, y = 150, min = 0, max = 200, vals = { 11,12 }, },
   },
}
