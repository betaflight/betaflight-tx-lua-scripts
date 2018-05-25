lcdResolution =
{
    low = 0,
    high = 1
}

local supportedPlatforms = {
    x7 =
    {
        templateHome    = SCRIPT_HOME.."/X7/",
        preLoad         = SCRIPT_HOME.."/X7/x7pre.lua",
        resolution      = lcdResolution.low
    },
    x9 =
    {
        templateHome    = SCRIPT_HOME.."/X9/",
        preLoad         = SCRIPT_HOME.."/X9/x9pre.lua",
        resolution      = lcdResolution.low
    },
    horus =
    {
        templateHome=SCRIPT_HOME.."/HORUS/",
        preLoad=SCRIPT_HOME.."/HORUS/horuspre.lua",
        resolution      = lcdResolution.high
    },
}

local supportedRadios =
{
    ["x7"] = supportedPlatforms.x7,
    ["x7s"] = supportedPlatforms.x7,
    ["xlite"] = supportedPlatforms.x7,
    ["x9d"] = supportedPlatforms.x9,
    ["x9d+"] = supportedPlatforms.x9,
    ["x9e"] = supportedPlatforms.x9,
    ["x10"] = supportedPlatforms.horus,
    ["x12s"] = supportedPlatforms.horus,
}

local ver, rad, maj, min, rev = getVersion()
local radio = supportedRadios[rad]

if not radio then
    error("Radio not supported: "..rad)
end

return radio
