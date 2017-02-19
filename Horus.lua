SetupPages = {
   {
      title = "PIDs",
      text = {
         { t = "Roll",  x = 60,  y = 40 },
         { t = "Pitch", x = 160, y = 40 },
         { t = "Yaw",   x = 260, y = 40 },
      },
      fields = {
         -- ROLL
         { t = "P", x = 36,  y = 68,  sp=30, i=1 },
         { t = "I", x = 36,  y = 96,  sp=30, i=2 },
         { t = "D", x = 36,  y = 124, sp=30, i=3 },
         -- PITCH
         { t = "P", x = 136, y = 68,  sp=34, i=4 },
         { t = "I", x = 136, y = 96,  sp=34, i=5 },
         { t = "D", x = 136, y = 124, sp=34, i=6 },
         -- YAW
         { t = "P", x = 236, y = 68,  sp=30, i=7 },
         { t = "I", x = 236, y = 96,  sp=30, i=8 },
      },
   },
   {
      title = "Rates",
      text = {
         { t = "Super rates", x = 14,  y = 40 },
      },
      fields = {
         -- Super Rate
         { t = "Roll",  x = 20,  y = 68, sp = 76, i=3 },
         { t = "Pitch", x = 20,  y = 96, sp = 76, i=4 },

         -- Roll + Pitch
         { t = "RC Rate",  x = 152, y = 80, sp = 94, i=1 },
         { t = "Expo",  x = 294, y = 80, sp = 68, i=2 },

         -- Yaw
         { t = "Yaw",   x = 20,  y = 128, sp = 76, i=5 },
         { t = "RC Rate",  x = 152, y = 128, sp = 94, i=12 },
         { t = "Expo",  x = 294, y = 128, sp = 68, i=11 },
      },
   },
   {
      title = "VTX",
      text = {},
      fields = {
         -- Super Rate
         { t = "Band",    x = 35,  y = 68, sp = 94, i=2, min=1, max=5, table = { "A", "B", "E", "F", "R" } },
         { t = "Channel", x = 35,  y = 96, sp = 94, i=3, min=1, max=8 },
         { t = "Power",   x = 35,  y = 124, sp = 94, i=4, min=1 },
         { t = "Pit",     x = 35,  y = 152, sp = 94, i=5, min=0, max=1, table = { [0]="OFF", "ON" } },
         { t = "Dev",     x = 240, y = 68, sp = 68, i=1, ro=true, table = {[3]="SmartAudio",[4]="Tramp"} },
         { t = "Freq",    x = 240, y = 96, sp = 68, i="f", ro=true },
      },
   }
}

MenuBox = { x=120, y=100, w=200, x_offset=68, h_line=20, h_offset=6 }
SaveBox = { x=120, y=100, w=180, x_offset=12,  h=60, h_offset=12 }
NoTelem = { 192, LCD_H - 28, "No telemetry", TEXT_COLOR + INVERS + BLINK }

backgroundFill = TEXT_BGCOLOR
foregroundColor = LINE_COLOR
globalTextOptions = TEXT_COLOR

local run_ui = assert(loadScript("/SCRIPTS/BF/ui.lua"))()

drawScreenTitle = function (title)
  lcd.drawFilledRectangle(0, 0, LCD_W, 30, TITLE_BGCOLOR)
  lcd.drawText(1, 5, title, MENU_TITLE_COLOR)
  --lcd.drawText(LCD_W-40, 5, page.."/"..pages, MENU_TITLE_COLOR)
end

return {run=run_ui}
