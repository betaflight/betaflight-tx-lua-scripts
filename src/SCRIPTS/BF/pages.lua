local PageFiles = {}

if apiVersion >= 1.036 then
    PageFiles[#PageFiles + 1] = { title = "VTX Settings", script = "vtx.lua" }
end

if apiVersion >= 1.016 then
    PageFiles[#PageFiles + 1] = { title = "PIDs 1", script = "pids1.lua" }
end

if apiVersion >= 1.021 then
    PageFiles[#PageFiles + 1] = { title = "PIDs 2", script = "pids2.lua" }
end

if apiVersion >= 1.016 then
    PageFiles[#PageFiles + 1] = { title = "Rates", script = "rates.lua" }
end

if apiVersion >= 1.016 then
    PageFiles[#PageFiles + 1] = { title = "Advanced PIDs", script = "pid_advanced.lua" }
end

if apiVersion >= 1.016 then
    PageFiles[#PageFiles + 1] = { title = "Filters 1", script = "filters1.lua" }
end

if apiVersion >= 1.042 then
    PageFiles[#PageFiles + 1] = { title = "Filters 2", script = "filters2.lua" }
end

if apiVersion >= 1.016 then
    PageFiles[#PageFiles + 1] = { title = "Gyro / Motor", script = "pwm.lua" }
end

if apiVersion >= 1.016 then
    PageFiles[#PageFiles + 1] = { title = "Receiver", script = "rx.lua" }
end

if apiVersion >= 1.041 then
    PageFiles[#PageFiles + 1] = { title = "GPS Rescue", script = "rescue.lua" }
end

if apiVersion >= 1.041 then
    PageFiles[#PageFiles + 1] = { title = "GPS PIDs", script = "gpspids.lua" }
end

return PageFiles
