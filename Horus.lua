SetupPages = {
   {
      title = "PIDs",
      text = {
         { t = "P",      x = 129,  y =  68 },
         { t = "I",      x = 209,  y =  68 },
         { t = "D",      x = 289,  y =  68 },
         { t = "ROLL",   x =  35,  y =  96 },
         { t = "PITCH",  x =  35,  y = 124 },
         { t = "YAW",    x =  35,  y = 152 },
      },
      fields = {
         -- P
         { x = 129, y =  96, i =  1 },
         { x = 129, y = 124, i =  4 },
         { x = 129, y = 152, i =  7 },
         -- I
         { x = 209, y =  96, i =  2 },
         { x = 209, y = 124, i =  5 },
         { x = 209, y = 152, i =  8 },
         -- D
         { x = 289, y =  96, i =  3 },
         { x = 289, y = 124, i =  6 },
         --{ x = 289, y = 152, i =  9 },
      },
   },
   {
      title = "Rates",
      text = {
         { t = "RC Rate",    x = 100,  y = 68 },
         { t = "Super Rate", x = 175,  y = 68 },
         { t = "RC Expo",    x = 280,  y = 68 },
         { t = "ROLL",   x =  35,  y =  96 },
         { t = "PITCH",  x =  35,  y = 124 },
         { t = "YAW",    x =  35,  y = 152 },
      },
      fields = {
         -- RC Rate
         { x = 129, y = 110, i =  1 },
         { x = 129, y = 152, i = 12 },
         -- Super Rate
         { x = 209, y =  96, i =  3 },
         { x = 209, y = 124, i =  4 },
         { x = 209, y = 152, i =  5 },
         -- RC Expo
         { x = 289, y = 110, i =  2 },
         { x = 289, y = 152, i = 11 },
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
         { t = "Dev",     x = 240, y = 68, sp = 68, i=1, ro=true, table = {[3]="SmartAudio",[4]="Tramp",[255]="None"} },
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
