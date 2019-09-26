PageFiles = 
{
    { title = "PIDs 1", script = "pids1.lua"},
    { title = "PIDs 2", script = "pids2.lua"},
    { title = "Rates", script = "rates.lua"},
    { title = "Advanced PIDs", script = "pid_advanced.lua"},
    { title = "Filters", script = "filters.lua"},
    { title = "vTX Settings", script = "vtx.lua"},
    { title = "Gyro / Motor", script = "pwm.lua"},
    { title = "Rx", script = "rx.lua"},
    { title = "GPS Rescue", script = "rescue.lua", requiredVersion = 1.041},
    { title = "GPS PIDs", script = "gpspids.lua", requiredVersion = 1.041},
}

MenuBox = { x=40, y=12, w=120, x_offset=36, h_line=8, h_offset=3 }
SaveBox = { x=40, y=12, w=120, x_offset=4,  h=30, h_offset=5 }
NoTelem = { 70, 55, "No Telemetry", BLINK }
