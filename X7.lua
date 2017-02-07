SetupPages = {
   {
      title = "PIDs",
      text = {
         { t = "Roll",  x = 1,  y = 12 },
         { t = "Pitch", x = 43, y = 12 },
         { t = "Yaw",   x = 85, y = 12 },
      },
      fields = {
         -- ROLL
         { t = "P", x = 1,  y = 24, i=1 },
         { t = "I", x = 1,  y = 34, i=2 },
         { t = "D", x = 1,  y = 44, i=3 },
         -- PITCH
         { t = "P", x = 43,  y = 24, i=4 },
         { t = "I", x = 43,  y = 34, i=5 },
         { t = "D", x = 43,  y = 44, i=6 },
         -- YAW
         { t = "P", x = 85, y = 24, i=7 },
         { t = "I", x = 85, y = 34, i=8 },
         --{ t = "D", x = 85, y = 44, i=9 },
      },
   },
   {
      title = "Rates",
      text = {
         { t = "S-Rates", x = 8,  y = 12 },
         { t = "RC",      x = 62, y = 12 },
         { t = "Expo",    x = 86, y = 12 },
      },
      fields = {
         -- Super Rate
         { t = "R", x = 1, y = 24, i=3 },
         { t = "P", x = 1, y = 34, i=4 },

         -- Roll + Pitch
         { x = 60, y = 29, i=1 },
         { x = 90, y = 29, i=2 },

         -- Yaw
         { t = "Y", x = 1,  y = 44, i=5 },
         {          x = 60, y = 44, i=12 },
         {          x = 90, y = 44, i=11 },
      },
   },
   {
      title = "VTX",
      text = {},
      fields = {
         -- Super Rate
         { t = "Band", x = 1, y = 12, sp = 34, i=2, min=1, max=5, table = { "A", "B", "E", "F", "R" } },
         { t = "Ch",   x = 1, y = 22, sp = 34, i=3, min=1, max=8 },
         { t = "Pw",   x = 1, y = 32, sp = 34, i=4, min=1 },
         { t = "Pit",  x = 1, y = 42, sp = 34, i=5, min=0, max=1, table = { [0]="OFF", "ON" } },
         { t = "Dev",  x = 60, y = 12, sp = 34, i=1, ro=true, table = {[3]="SA",[4]="Tramp"} },
         { t = "Freq", x = 60, y = 22, sp = 34, i="f", ro=true },
      },
   }
}

MenuBox = { x=1, y=10, w=100, x_offset=36, h_line=10, h_offset=3 }
SaveBox = { x=20, y=12, w=100, x_offset=4,  h=30, h_offset=5 }
NoTelem = { 36, 55, "No Telemetry", BLINK }

local run_ui = assert(loadScript("/SCRIPTS/BF/ui.lua"))()
return {run=run_ui}
