local function precondition()
    local hasVtxTable = loadScript("VTX_TABLES/"..mcuId..".lua")
    collectgarbage()
    if hasVtxTable then
        return nil
    else
        return "CONFIRM/vtx_tables.lua"
    end
end

return precondition()
