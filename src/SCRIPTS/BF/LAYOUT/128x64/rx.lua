return {
    yMinLimit      = 12,
    yMaxLimit      = 52,
    text = {},
    fields = {
       { t = "Stick Min",  x =  10, y = 20, sp = 45, min = 1000, max = 2000, vals = { 6, 7 }, },
       { t = "Stick Mid",  x =  10, y = 30, sp = 45, min = 1000, max = 2000, vals = { 4, 5 }, },
       { t = "Stick Max",  x =  10, y = 40, sp = 45, min = 1000, max = 2000, vals = { 2, 3 }, },
       { t = "Cam Angle",  x =  10, y = 50, sp = 50, min = 0, max = 90, vals = { 23 }, },
       { t = "Interp",     x =  10, y = 60, sp = 50, min = 0, max = 3, vals = { 13 }, table={ [0]="Off", "Preset", "Auto", "Manual"} },
       { t = "Interp Int", x =  10, y = 70, sp = 50, min = 1, max = 50, vals = { 14 }, },
    },
 }