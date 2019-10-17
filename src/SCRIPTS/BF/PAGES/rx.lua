local display = assert(loadScript(radio.templateHome.."rx.lua"))()
return {
    read           = 44, -- MSP_RX_CONFIG
    write          = 45, -- MSP_SET_RX_CONFIG
    title          = "RX",
    reboot         = false,
    eepromWrite    = true,
    minBytes       = 23,
    labels         = display.labels,
    fieldLayout    = display.fieldLayout,
    fields         = {
      { min = 1000, max = 2000, vals = { 6, 7 }, },
      { min = 1000, max = 2000, vals = { 4, 5 }, },
      { min = 1000, max = 2000, vals = { 2, 3 }, },
      { min = 0,    max = 90,   vals = { 23 },   },
      { min = 0,    max = 3,    vals = { 13 }, table={ [0]="Off", "Preset", "Auto", "Manual"} },
      { min = 1,    max = 50,   vals = { 14 },   }
    },
}
