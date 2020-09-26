local supportedRadios =
{
    ["128x64"]  = 
    {
        msp = {
            templateHome    = "TEMPLATES/128x64/",
            MenuBox         = { x=15, y=12, w=100, x_offset=36, h_line=8, h_offset=3 },
            SaveBox         = { x=15, y=12, w=100, x_offset=4,  h=30, h_offset=5 },
            NoTelem         = { 30, 55, "No Telemetry", BLINK },
            textSize        = SMLSIZE,
            yMinLimit       = 12,
            yMaxLimit       = 52,
        },
        cms = {
            rows = 8,
            cols = 26,
            pixelsPerRow = 8,
            pixelsPerChar = 5,
            xIndent = 0,
            yOffset = 0,
            textSize = SMLSIZE,
            refresh = {
                event = EVT_VIRTUAL_ENTER,
                text = "Refresh: [ENT]",
                top = 1,
                left = 64,
            },
        },
    },
    ["128x96"]  = 
    {
        msp = {
            templateHome    = "TEMPLATES/128x96/",
            MenuBox         = { x=15, y=12, w=100, x_offset=36, h_line=8, h_offset=3 },
            SaveBox         = { x=15, y=12, w=100, x_offset=4,  h=30, h_offset=5 },
            NoTelem         = { 30, 87, "No Telemetry", BLINK },
            textSize        = SMLSIZE,
            yMinLimit       = 12,
            yMaxLimit       = 84,
        },
        cms = {
            rows = 12,
            cols = 26,
            pixelsPerRow = 8,
            pixelsPerChar = 5,
            xIndent = 0,
            yOffset = 0,
            textSize = SMLSIZE,
            refresh = {
                event = EVT_VIRTUAL_ENTER,
                text = "Refresh: [ENT]",
                top = 1,
                left = 64,
            },
        },
    },
    ["212x64"]  = 
    {
        msp = {
            templateHome    = "TEMPLATES/212x64/",
            MenuBox         = { x=40, y=12, w=120, x_offset=36, h_line=8, h_offset=3 },
            SaveBox         = { x=40, y=12, w=120, x_offset=4,  h=30, h_offset=5 },
            NoTelem         = { 70, 55, "No Telemetry", BLINK },
            textSize        = SMLSIZE,
            yMinLimit       = 12,
            yMaxLimit       = 52,
        },
        cms = {
            rows = 8,
            cols = 32,
            pixelsPerRow = 8,
            pixelsPerChar = 6,
            xIndent = 0,
            yOffset = 0,
            textSize = SMLSIZE,
            refresh = {
                event = EVT_VIRTUAL_INC,
                text = "Refresh: [+]",
                top = 1,
                left = 156,
            }
        },
    },
    ["480x272"] = 
    {
        msp = {
            templateHome    = "TEMPLATES/480x272/",
            highRes         = true,
            MenuBox         = { x=120, y=100, w=200, x_offset=68, h_line=20, h_offset=6 },
            SaveBox         = { x=120, y=100, w=180, x_offset=12, h=60, h_offset=12 },
            NoTelem         = { 192, LCD_H - 28, "No Telemetry", (TEXT_COLOR or 0) + INVERS + BLINK },
            textSize        = 0,
            yMinLimit       = 35,
            yMaxLimit       = 235,
        },
        cms = {
            rows = 9,
            cols = 32,
            pixelsPerRow = 24,
            pixelsPerChar = 14,
            xIndent = 14,
            yOffset = 32,
            textSize = MIDSIZE,
            refresh = {
                event = EVT_VIRTUAL_ENTER,
                text = "Refresh: [ENT]",
                top = 1,
                left = 300,
            }
        },
    },
    ["320x480"] = 
    {
        msp = {
            templateHome    = "TEMPLATES/320x480/",
            highRes         = true,
            MenuBox         = { x= (LCD_W -200)/2, y=LCD_H/2, w=200, x_offset=68, h_line=20, h_offset=6 },
            SaveBox         = { x= (LCD_W -200)/2, y=LCD_H/2, w=180, x_offset=12, h=60, h_offset=12 },
            NoTelem         = { LCD_W/2 - 50, LCD_H - 28, "No Telemetry", (TEXT_COLOR or 0) + INVERS + BLINK },
            textSize        = 0,
            yMinLimit       = 35,
            yMaxLimit       = 435,
        },
        cms = nil,
    },
}

local resolution = LCD_W.."x"..LCD_H
local radio = assert(supportedRadios[resolution], resolution.." not supported")

return radio
