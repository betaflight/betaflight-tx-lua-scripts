local display = assert(loadScript(radio.templateHome.."rates.lua"))()
return {
    read              = 111, -- MSP_RC_TUNING
    write             = 204, -- MSP_SET_RC_TUNING
    title             = "Rates",
    reboot            = false,
    eepromWrite       = true,
    minBytes          = 16,
    yMinLimit         = display.yMinLimit,
    yMaxLimit         = display.yMaxLimit,
    text              = display.text,
    fieldLayout       = display.fieldLayout,
    fields            = {
        { vals = { 1 },     min = 0,    max = 255, scale = 100, },
        { vals = { 13 },    min = 0,    max = 255, scale = 100, },
        { vals = { 12 },    min = 0,    max = 255, scale = 100, },
        { vals = { 3 },     min = 0,    max = 100, scale = 100, },
        { vals = { 4 },     min = 0,    max = 100, scale = 100, },
        { vals = { 5 },     min = 0,    max = 255, scale = 100, },
        { vals = { 2 },     min = 0,    max = 100, scale = 100, },
        { vals = { 14 },    min = 0,    max = 100, scale = 100, },
        { vals = { 11 },    min = 0,    max = 100, scale = 100, },
        { vals = { 7 },     min = 0,    max = 100, scale = 100, },
        { vals = { 8 },     min = 0,    max = 100, scale = 100, },
        { vals = { 15 },    min = 0,    max = 2, table = { [0] = "OFF", "SCALE", "CLIP" } },
        { vals = { 16 },    min = 25,   max = 100, },
        { vals = { 6 } ,    min = 0,    max = 100, scale = 100, },
        { vals = { 9, 10 }, min = 1000, max = 2000, },
    },
}
