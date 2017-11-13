return {
	read           = 44, -- MSP_RX_CONFIG
	write          = 45, -- MSP_SET_RX_CONFIG
	title          = "RX",
	reboot         = false,
	eepromWrite    = true,
	minBytes       = 23,
	text= {
		{ t = "Stick Min",  x = 50,   y = 65  },	
		{ t = "Stick Mid",  x = 50,   y = 110 },
		{ t = "Stick Max",  x = 50,   y = 155 },
		{ t = "Cam Angle",  x = 240,  y = 65  },
		{ t = "Interp",     x = 240,  y = 110 },
		{ t = "Interp Int", x = 240,  y = 155 }
	},
	fields = {
		{ x =  140, y = 50,  min = 1000, max = 2000, vals = { 6, 7 } },
		{ x =  140, y = 96,  min = 1000, max = 2000, vals = { 4, 5 } },
		{ x =  140, y = 140, min = 1000, max = 2000, vals = { 2, 3 } },
		{ x =  350, y = 50,  min = 0,    max = 50,   vals = { 23 }   },
		{ x =  350, y = 95,  min = 0,    max = 3,    vals = { 13 },  table={ [0]="Off", "Preset", "Auto", "Manual"} },
		{ x =  350, y = 140, min = 1,    max = 50,   vals = { 14 }   }
	},
}
