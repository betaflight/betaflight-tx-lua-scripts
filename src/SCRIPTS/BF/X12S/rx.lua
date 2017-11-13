return {
	read           = 44, -- MSP_RX_CONFIG
	write          = 45, -- MSP_SET_RX_CONFIG
	title          = "RX",
	reboot         = false,
	eepromWrite    = true,
	minBytes       = 23,
	text= {
		{ t = "Stick Min",  x = 50,   y = 68  },
		{ t = "Stick Mid",  x = 50,   y = 110 },
		{ t = "Stick Max",  x = 50,   y = 155 },
		{ t = "Cam Angle",  x = 240,  y = 68  },
		{ t = "Interp",     x = 240,  y = 110 },
		{ t = "Interp Int", x = 240,  y = 155 }
	},
	fields = {
		{ x =  152, y = 68,  min = 1000, max = 2000, vals = { 6, 7 } },
		{ x =  152, y = 110, min = 1000, max = 2000, vals = { 4, 5 } },
		{ x =  152, y = 155, min = 1000, max = 2000, vals = { 2, 3 } },
		{ x =  362, y = 68,  min = 0,    max = 50,   vals = { 23 }   },
		{ x =  362, y = 110, min = 0,    max = 3,    vals = { 13 },
                  table={ [0]="Off", "Preset", "Auto", "Manual"} },
		{ x =  362, y = 155, min = 1,    max = 50,   vals = { 14 }   }
	},
}
