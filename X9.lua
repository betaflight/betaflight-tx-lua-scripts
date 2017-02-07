SetupPages = {
   {
      title = "PIDs",
      text = {
         { t = "Roll",  x = 21,  y = 14 },
         { t = "Pitch", x = 75,  y = 14 },
         { t = "Yaw",   x = 129, y = 14 },
      },
      fields = {
         -- ROLL
         { t = "P", x = 25,  y = 24 },
         { t = "I", x = 25,  y = 34 },
         { t = "D", x = 25,  y = 44 },
         -- PITCH
         { t = "P", x = 80,  y = 24 },
         { t = "I", x = 80,  y = 34 },
         { t = "D", x = 80,  y = 44 },
         -- YAW
         { t = "P", x = 135, y = 24 },
         { t = "I", x = 135, y = 34 },
         --{ t = "D", x = 135, y = 44, i=9 },
      },
   },
   {
      title = "Rates",
      text = {
         { t = "Super rates", x = 5,  y = 14 },
         { t = "RC",          x = 80, y = 14 }
      },
      fields = {
         -- Super Rate
         { t = "Roll",  x = 10,  y = 24, sp = 40, i=3 },
         { t = "Pitch", x = 10,  y = 34, sp = 40, i=4 },

         -- Roll + Pitch
         { t = "Rate",  x = 75,  y = 29, sp = 30, i=1 },
         { t = "Expo",  x = 135, y = 29, sp = 30, i=2 },

         -- Yaw
         { t = "Yaw",   x = 10,  y = 48, sp = 40, i=5 },
         { t = "Rate",  x = 75,  y = 48, sp = 30, i=12 },
         { t = "Expo",  x = 135, y = 48, sp = 30, i=11 },
      },
   },
   {
      title = "VTX",
      text = {},
      fields = {
         -- Super Rate
         { t = "Band",    x = 25,  y = 14, sp = 50, i=2, min=1, max=5, table = { "A", "B", "E", "F", "R" } },
         { t = "Channel", x = 25,  y = 24, sp = 50, i=3, min=1, max=8 },
         { t = "Power",   x = 25,  y = 34, sp = 50, i=4, min=1 },
         { t = "Pit",     x = 25,  y = 44, sp = 50, i=5, min=0, max=1, table = { [0]="OFF", "ON" } },
         { t = "Dev",     x = 100, y = 14, sp = 32, i=1, ro=true, table = {[3]="SmartAudio",[4]="Tramp"} },
         { t = "Freq",    x = 100, y = 24, sp = 32, i="f", ro=true },
      },
   }
}

MenuBox = { x=40, y=12, w=120, x_offset=36, h_line=8, h_offset=3 }
SaveBox = { x=40, y=12, w=120, x_offset=4,  h=30, h_offset=5 }
NoTelem = { 70, 55, "No Telemetry", BLINK }

local run_ui = assert(loadScript("/SCRIPTS/BF/ui.lua"))()
return {run=run_ui}
