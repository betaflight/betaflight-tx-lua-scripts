return {
   text = {

      { t = "Min Sats.",      x =  3,  y = 10,   },
      { t = "Angle",          x =  3,  y = 20,   },
      { t = "Initial Alt",    x =  3,  y = 30,   },
      { t = "Descent Dst",    x =  3,  y = 40,   },
      { t = "Ground Spd",     x =  3,  y = 50,   },
      { t = "Snty.",          x =  80,   y = 10, },
      { t = "Throttle",       x =  80,   y = 20, },
      { t = "Min",            x =  85,   y = 30, },
      { t = "Hover",          x =  80,   y = 40, },
      { t = "Max",            x =  85,   y = 50, },
   },
   fields = {
      { x = 58, y = 10, min =    0, max =  50, vals = { 16  }, },
      { x = 58, y = 20, min =    0, max = 200, vals = { 1,2 }, },
      { x = 58, y = 30, min =   20, max = 100, vals = { 3,4 }, },
      { x = 58, y = 40, min =   30, max = 500, vals = { 5,6 }, },
      { x = 58, y = 50, min =   30, max =3000, vals = { 7,8 }, },
      { x = 105, y = 10, min =   0,  max = 2   , vals = { 15    } ,table = { [0]="OFF","ON","FS_ONLY"}, },
      { x = 105, y = 30, min = 1000, max = 2000, vals =   { 9,10 }, },
      { x = 105, y = 40, min = 1000, max = 2000, vals =  { 13,14 }, },
      { x = 105, y = 50, min = 1000, max = 2000, vals =  { 11,12 }, },
   },
}
