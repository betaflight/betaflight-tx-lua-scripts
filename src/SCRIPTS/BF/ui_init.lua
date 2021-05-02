local apiVersionReceived = false
local vtxTablesReceived = false
local data_init, getVtxTables, getMCUId
local returnTable = { f = nil, t = "" }

local function modelActive()
    return getValue(protocol.stateSensor) > 0
end

local function init()
    if not modelActive() then
        returnTable.t = "Waiting for connection"
    elseif apiVersion == 0 then
        data_init = data_init or assert(loadScript("data_init.lua"))()
        returnTable.t = data_init.t
        data_init.f()
    elseif apiVersion > 0 and not apiVersionReceived then
        data_init = nil
        apiVersionReceived = true
        collectgarbage()
    elseif apiVersion >= 1.042 and not mcuId then
        getMCUId = getMCUId or assert(loadScript("mcu_id.lua"))()
        returnTable.t = getMCUId.t
        if getMCUId.f() then
            getMCUId = nil
            local vtxTables = loadScript("/BF/VTX/"..mcuId..".lua")
            if vtxTables and vtxTables() then
                vtxTablesReceived = true
                vtxTables = nil
            end
            collectgarbage()
        end
    elseif apiVersion >= 1.042 and not vtxTablesReceived then
        getVtxTables = getVtxTables or assert(loadScript("vtx_tables.lua"))()
        returnTable.t = getVtxTables.t
        vtxTablesReceived = getVtxTables.f()
        if vtxTablesReceived then
            getVtxTables = nil
            collectgarbage()
        end
    else
        return true
    end
    return apiVersionReceived and vtxTablesReceived and mcuId
end

returnTable.f = init

return returnTable
