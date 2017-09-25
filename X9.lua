G_MIN_FREQ_VAL = 5000
G_MAX_FREQ_VAL = 5999

SetupPages = {
   {
      title = "PIDs",
      text = {
         { t = "P",      x =  72,  y = 14 },
         { t = "I",      x = 100,  y = 14 },
         { t = "D",      x = 128,  y = 14 },
         { t = "ROLL",   x =  25,  y = 26 },
         { t = "PITCH",  x =  25,  y = 36 },
         { t = "YAW",    x =  25,  y = 46 },
      },
      fields = {
         -- P
         { x =  66, y = 26, i =  1 },
         { x =  66, y = 36, i =  4 },
         { x =  66, y = 46, i =  7 },
         -- I
         { x =  94, y = 26, i =  2 },
         { x =  94, y = 36, i =  5 },
         { x =  94, y = 46, i =  8 },
         -- D
         { x = 122, y = 26, i =  3 },
         { x = 122, y = 36, i =  6 },
         --{ x = 122, y = 46, i =  9 },
      },
   },
   {
      title = "Rates",
      text = {
         { t = "RC",     x =  65,  y = 11, to = SMLSIZE },
         { t = "Rate",   x =  65,  y = 18, to = SMLSIZE },
         { t = "Super",  x =  91,  y = 11, to = SMLSIZE },
         { t = "Rate",   x =  91,  y = 18, to = SMLSIZE },
         { t = "RC",     x = 121,  y = 11, to = SMLSIZE },
         { t = "Expo",   x = 121,  y = 18, to = SMLSIZE },
         { t = "ROLL",   x =  25,  y = 26 },
         { t = "PITCH",  x =  25,  y = 36 },
         { t = "YAW",    x =  25,  y = 46 },
      },
      fields = {
         -- RC Rate
         { x =  66, y = 31, i =  1 },
         { x =  66, y = 46, i = 12 },
         -- Super Rate
         { x =  94, y = 26, i =  3 },
         { x =  94, y = 36, i =  4 },
         { x =  94, y = 46, i =  5 },
         -- RC Expo
         { x = 122, y = 31, i =  2 },
         { x = 122, y = 46, i = 11 },
      },
   },
   {
      title = "VTX",
      text = {},
      fields = {
         -- VTX Settings
         { t = "Band",    x = 25,  y = 14, sp = 50, i=2, min=0, max=5, table = { [0]="U", "A", "B", "E", "F", "R" } },
         { t = "Channel", x = 25,  y = 24, sp = 50, i=3, min=1, max=8 },
         { t = "Power",   x = 25,  y = 34, sp = 50, i=4, min=1 },
         { t = "Pit",     x = 25,  y = 44, sp = 50, i=5, min=0, max=1, table = { [0]="OFF", "ON" } },
         { t = "Dev",     x = 100, y = 14, sp = 32, i=1, ro=true, table = {[3]="SmartAudio",[4]="Tramp",[255]="None"} },
         { t = "Freq",    x = 100, y = 24, sp = 32, i="f", min=G_MIN_FREQ_VAL, max=G_MAX_FREQ_VAL },
      },
   }
}

MenuBox = { x=40, y=12, w=120, x_offset=36, h_line=8, h_offset=3 }
SaveBox = { x=40, y=12, w=120, x_offset=4,  h=30, h_offset=5 }
NoTelem = { 70, 55, "No Telemetry", BLINK }

local run_ui = assert(loadScript("/SCRIPTS/BF/ui.lua"))()
return {run=run_ui}
