lcdResolution =
{
    low = 0,
    high = 1
}


local supportedRadios =
{
    ["x7"] =
    {
        templateHome    = SCRIPT_HOME.."/X7/",
        preLoad         = SCRIPT_HOME.."/X7/x7pre.lua"
    },
    ["x9d"] =
    {
        templateHome    = SCRIPT_HOME.."/X9/",
        preLoad         = SCRIPT_HOME.."/X9/x9pre.lua"
    },
    ["x9d+"] =
    {
        templateHome    = SCRIPT_HOME.."/X9/",
        preLoad         = SCRIPT_HOME.."/X9/x9pre.lua"
    },
    ["x12s"] =
    {
        templateHome=SCRIPT_HOME.."/X12S/",
        preLoad=SCRIPT_HOME.."/X12S/x12spre.lua",
        resolution      = lcdResolution.high
    },
}

local ver, rad, maj, min, rev = getVersion()
local radio = supportedRadios[rad]

if not radio then
    error("Radio not supported: "..rad)
end

return radio
