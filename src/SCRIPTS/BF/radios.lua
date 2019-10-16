lcdResolution =
{
    low = 0,
    high = 1
}

local supportedRadios =
{
    ["128x64"]  = 
    {
        templateHome    = SCRIPT_HOME.."/128x64/",
        preLoad         = SCRIPT_HOME.."/128x64/pre.lua",
        resolution      = lcdResolution.low
    },
    ["212x64"]  = 
    {
        templateHome    = SCRIPT_HOME.."/212x64/",
        preLoad         = SCRIPT_HOME.."/212x64/pre.lua",
        resolution      = lcdResolution.low
    },
    ["480x272"] = 
    {
        templateHome    = SCRIPT_HOME.."/480x272/",
        preLoad         = SCRIPT_HOME.."/480x272/pre.lua",
        resolution      = lcdResolution.high
    },
    ["320x480"] = 
    {
        templateHome    = SCRIPT_HOME.."/320x480/",
        preLoad         = SCRIPT_HOME.."/320x480/pre.lua",
        resolution      = lcdResolution.high
    },
}

local ver, rad, maj, min, rev = getVersion()
local radio = supportedRadios[tostring(LCD_W) .. "x" .. tostring(LCD_H)]

if not radio then
    error("Radio not supported: "..rad)
end

return radio
