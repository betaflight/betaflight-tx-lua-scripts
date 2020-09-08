local apiVersionReceived = false
local vtxTablesReceived = false
local data_init, getVtxTables, getMCUId

local function init()
    if apiVersion == 0 then
        lcd.drawText(6, radio.yMinLimit, "Waiting for connection")
        data_init = data_init or assert(loadScript("data_init.lua"))()
        data_init()
    elseif apiVersion > 0 and not apiVersionReceived then
        data_init = nil
        apiVersionReceived = true
        collectgarbage()
    elseif apiVersion >= 1.042 and not mcuId then
        lcd.drawText(6, radio.yMinLimit, "Waiting for device ID")
        getMCUId = getMCUId or assert(loadScript("mcu_id.lua"))()
        if getMCUId() then
            getMCUId = nil
            local vtxTables = loadScript("/BF/VTX/"..mcuId..".lua")
            if vtxTables and vtxTables() then
                vtxTablesReceived = true
                vtxTables = nil
            end
            collectgarbage()
        end
    elseif apiVersion >= 1.042 and not vtxTablesReceived then
        lcd.drawText(6, radio.yMinLimit, "Downloading VTX Tables")
        getVtxTables = getVtxTables or assert(loadScript("vtx_tables.lua"))()
        vtxTablesReceived = getVtxTables()
        if vtxTablesReceived then
            getVtxTables = nil
            collectgarbage()
        end
    else
        return true
    end
    return apiVersionReceived and vtxTablesReceived and mcuId
end

return init
