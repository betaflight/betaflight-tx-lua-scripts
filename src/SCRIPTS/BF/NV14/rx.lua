return {
	read           = 44, -- MSP_RX_CONFIG
	write          = 45, -- MSP_SET_RX_CONFIG
	title          = "RX",
	reboot         = false,
	eepromWrite    = true,
	minBytes       = 23,
	text= {
		{ t = "Stick Min",  x = 36,   y = 68  },
		{ t = "Stick Mid",  x = 36,   y = 110 },
		{ t = "Stick Max",  x = 36,   y = 155 },
		{ t = "Cam Angle",  x = 36,  y = 200 },
		{ t = "Interp",     x = 36,  y = 242 },
		{ t = "Interp Int", x = 36,  y = 284 }
	},
	fields = {
		{ x =  150, y = 68,  min = 1000, max = 2000, vals = { 6, 7 }, to = MIDSIZE },
		{ x =  150, y = 110, min = 1000, max = 2000, vals = { 4, 5 }, to = MIDSIZE },
		{ x =  150, y = 155, min = 1000, max = 2000, vals = { 2, 3 }, to = MIDSIZE },
		{ x =  150, y = 200, min = 0,    max = 90,   vals = { 23 },   to = MIDSIZE },
		{ x =  150, y = 242, min = 0,    max = 3,    vals = { 13 },   to = MIDSIZE, table={ [0]="Off", "Preset", "Auto", "Manual"} },
		{ x =  150, y = 284, min = 1,    max = 50,   vals = { 14 },   to = MIDSIZE }
	},
}
