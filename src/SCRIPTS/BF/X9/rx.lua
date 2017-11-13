return {
   read           = 44, -- MSP_RX_CONFIG
   write          = 45, -- MSP_SET_RX_CONFIG
   title          = "RX",
   reboot         = false,
   eepromWrite    = true,
   minBytes       = 23,
   text = {},
   fields = {
      { t = "Stick Min",  x =  30, y = 20, sp = 45, min = 1000, max = 2000, vals = { 6, 7 }, to = SMLSIZE },
      { t = "Stick Mid",  x =  30, y = 30, sp = 45, min = 1000, max = 2000, vals = { 4, 5 }, to = SMLSIZE },
      { t = "Stick Max",  x =  30, y = 40, sp = 45, min = 1000, max = 2000, vals = { 2, 3 }, to = SMLSIZE },
      { t = "Cam Angle",  x =  110, y = 20, sp = 50, min = 0, max = 50, vals = { 23 }, to = SMLSIZE },
      { t = "Interp",     x =  110, y = 30, sp = 50, min = 0, max = 3, vals = { 13 }, to = SMLSIZE, table={ [0]="Off", "Preset", "Auto", "Manual"} },
      { t = "Interp Int", x =  110, y = 40, sp = 50, min = 1, max = 50, vals = { 14 }, to = SMLSIZE },
   },
}