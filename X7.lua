G_MIN_FREQ_VAL = 5000
G_MAX_FREQ_VAL = 5999

SetupPages = {
   {
      title = "PIDs",
      text = {
         { t = "P",      x =  48,  y = 14 },
         { t = "I",      x =  76,  y = 14 },
         { t = "D",      x = 104,  y = 14 },
         { t = "ROLL",   x =   1,  y = 26 },
         { t = "PITCH",  x =   1,  y = 36 },
         { t = "YAW",    x =   1,  y = 46 },
      },
      fields = {
         -- P
         { x = 42, y = 26, i =  1 },
         { x = 42, y = 36, i =  4 },
         { x = 42, y = 46, i =  7 },
         -- I
         { x = 70, y = 26, i =  2 },
         { x = 70, y = 36, i =  5 },
         { x = 70, y = 46, i =  8 },
         -- D
         { x = 98, y = 26, i =  3 },
         { x = 98, y = 36, i =  6 },
         --{ x = 98, y = 46, i =  9 },
      },
   },
   {
      title = "Rates",
      text = {
         { t = "RC",     x =  41,  y = 11, to = SMLSIZE },
         { t = "Rate",   x =  41,  y = 18, to = SMLSIZE },
         { t = "Super",  x =  67,  y = 11, to = SMLSIZE },
         { t = "Rate",   x =  67,  y = 18, to = SMLSIZE },
         { t = "RC",     x =  97,  y = 11, to = SMLSIZE },
         { t = "Expo",   x =  97,  y = 18, to = SMLSIZE },
         { t = "ROLL",   x =   1,  y = 26 },
         { t = "PITCH",  x =   1,  y = 36 },
         { t = "YAW",    x =   1,  y = 46 },
      },
      fields = {
         -- RC Rate
         { x = 42, y = 31, i =  1 },
         { x = 42, y = 46, i = 12 },
         -- Super Rate
         { x = 70, y = 26, i =  3 },
         { x = 70, y = 36, i =  4 },
         { x = 70, y = 46, i =  5 },
         -- RC Expo
         { x = 98, y = 31, i =  2 },
         { x = 98, y = 46, i = 11 },
      },
   },
   {
      title = "VTX",
      text = {},
      fields = {
         -- VTX Settings
         { t = "Band", x = 1, y = 12, sp = 34, i=2, min=0, max=5, table = { [0]="U", "A", "B", "E", "F", "R" } },
         { t = "Ch",   x = 1, y = 22, sp = 34, i=3, min=1, max=8 },
         { t = "Pw",   x = 1, y = 32, sp = 34, i=4, min=1 },
         { t = "Pit",  x = 1, y = 42, sp = 34, i=5, min=0, max=1, table = { [0]="OFF", "ON" } },
         { t = "Dev",  x = 60, y = 12, sp = 34, i=1, ro=true, table = {[3]="SA",[4]="Tramp",[255]="None"} },
         { t = "Freq", x = 60, y = 22, sp = 34, i="f", min=G_MIN_FREQ_VAL, max=G_MAX_FREQ_VAL },
      },
   }
}

MenuBox = { x=1, y=10, w=100, x_offset=36, h_line=10, h_offset=3 }
SaveBox = { x=20, y=12, w=100, x_offset=4,  h=30, h_offset=5 }
NoTelem = { 36, 55, "No Telemetry", BLINK }

local run_ui = assert(loadScript("/SCRIPTS/BF/ui.lua"))()
return {run=run_ui}
