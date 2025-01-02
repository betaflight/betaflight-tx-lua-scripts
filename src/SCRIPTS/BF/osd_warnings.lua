local osdWarnings = {}

osdWarnings.warnings = {
    { id = 1, message = "Arming status flag" },
    { id = 2, message = "Sanity check" },
    { id = 3, message = "GPS Rescue status" },
    { id = 4, message = "Battery voltage warning" },
    { id = 5, message = "RSSI warning" },
    { id = 6, message = "Failsafe warning" },
}

function osdWarnings.process()
    for _, warning in ipairs(osdWarnings.warnings) do
        playFile(warning.message)
    end
end

return osdWarnings
