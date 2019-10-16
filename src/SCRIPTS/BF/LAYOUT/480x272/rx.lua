return {
	text= {
		{ t = "Stick Min",  x = 36,   y = 68  },
		{ t = "Stick Mid",  x = 36,   y = 110 },
		{ t = "Stick Max",  x = 36,   y = 155 },
		{ t = "Cam Angle",  x = 232,  y = 68  },
		{ t = "Interp",     x = 232,  y = 110 },
		{ t = "Interp Int", x = 232,  y = 155 }
	},
	fields = {
		{ x =  130, y = 68,  min = 1000, max = 2000, vals = { 6, 7 }, },
		{ x =  130, y = 110, min = 1000, max = 2000, vals = { 4, 5 }, },
		{ x =  130, y = 155, min = 1000, max = 2000, vals = { 2, 3 }, },
		{ x =  350, y = 68,  min = 0,    max = 90,   vals = { 23 },   },
		{ x =  350, y = 110, min = 0,    max = 3,    vals = { 13 }, table={ [0]="Off", "Preset", "Auto", "Manual"} },
		{ x =  350, y = 155, min = 1,    max = 50,   vals = { 14 },   }
	},
}
