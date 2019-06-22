PageFiles =
{
    "pids1.lua",
    "pids2.lua",
    "rates.lua",
    "pid_advanced.lua",
    "filters.lua",
    "pwm.lua",
    "rx.lua",
    "vtx.lua",
    "rescue.lua",
    "gpspids.lua",
}

MenuBox = { x= (LCD_W -200)/2, y=LCD_H/2, w=200, x_offset=68, h_line=20, h_offset=6 }
SaveBox = { x= (LCD_W -200)/2, y=LCD_H/2, w=180, x_offset=12, h=60, h_offset=12 }
NoTelem = { LCD_W/2 - 50, LCD_H - 28, "No Telemetry", TEXT_COLOR + INVERS + BLINK }
