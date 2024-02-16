local function precondition()
    if apiVersion < 1.44 then
        -- BOARD_INFO is unavailable below 1.44
        return nil
    end
    local hasBoardInfo = loadScript("BOARD_INFO/"..mcuId..".lua")
    collectgarbage()
    if hasBoardInfo then
        return nil
    else
        return "CONFIRM/pwm.lua"
    end
end

return precondition()
