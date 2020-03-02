local apiVersionReceived = false
local vtxTablesReceived = false
local data_init, getVtxTables
local vtxTables = loadScript("/BF/VTX/"..model.getInfo().name..".lua")

if vtxTables and vtxTables() then
    vtxTablesReceived = true
    vtxTables = nil
    collectgarbage()
end

local function init()
    if apiVersion == 0 then
        lcd.drawText(6, radio.yMinLimit, "Initialising")
        data_init = data_init or assert(loadScript("data_init.lua"))()
        data_init()
    elseif apiVersion > 0 and not apiVersionReceived then
        data_init = nil
        apiVersionReceived = true
        collectgarbage()
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
    return apiVersionReceived and vtxTablesReceived
end

return init
