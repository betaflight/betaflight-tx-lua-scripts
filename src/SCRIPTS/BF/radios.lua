local supportedRadios =
{
    ["128x64"]  = 
    {
        templateHome    = "TEMPLATES/128x64/",
        MenuBox         = { x=15, y=12, w=100, x_offset=36, h_line=8, h_offset=3 },
        SaveBox         = { x=15, y=12, w=100, x_offset=4,  h=30, h_offset=5 },
        NoTelem         = { 30, 55, "No Telemetry", BLINK },
        textSize        = SMLSIZE,
        yMinLimit       = 12,
        yMaxLimit       = 52,
    },
    ["212x64"]  = 
    {
        templateHome    = "TEMPLATES/212x64/",
        MenuBox         = { x=40, y=12, w=120, x_offset=36, h_line=8, h_offset=3 },
        SaveBox         = { x=40, y=12, w=120, x_offset=4,  h=30, h_offset=5 },
        NoTelem         = { 70, 55, "No Telemetry", BLINK },
        textSize        = SMLSIZE,
        yMinLimit       = 12,
        yMaxLimit       = 52,
    },
    ["480x272"] = 
    {
        templateHome    = "TEMPLATES/480x272/",
        highRes         = true,
        MenuBox         = { x=120, y=100, w=200, x_offset=68, h_line=20, h_offset=6 },
        SaveBox         = { x=120, y=100, w=180, x_offset=12, h=60, h_offset=12 },
        NoTelem         = { 192, LCD_H - 28, "No Telemetry", (TEXT_COLOR or 0) + INVERS + BLINK },
        textSize        = 0,
        yMinLimit       = 35,
        yMaxLimit       = 235,
    },
    ["320x480"] = 
    {
        templateHome    = "TEMPLATES/320x480/",
        highRes         = true,
        MenuBox         = { x= (LCD_W -200)/2, y=LCD_H/2, w=200, x_offset=68, h_line=20, h_offset=6 },
        SaveBox         = { x= (LCD_W -200)/2, y=LCD_H/2, w=180, x_offset=12, h=60, h_offset=12 },
        NoTelem         = { LCD_W/2 - 50, LCD_H - 28, "No Telemetry", (TEXT_COLOR or 0) + INVERS + BLINK },
        textSize        = 0,
        yMinLimit       = 35,
        yMaxLimit       = 435,
    },
}

local resolution = LCD_W.."x"..LCD_H
local radio = assert(supportedRadios[resolution], resolution.." not supported")

return radio
