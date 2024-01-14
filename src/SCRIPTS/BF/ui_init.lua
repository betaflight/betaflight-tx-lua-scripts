local apiVersionReceived = false
local vtxTablesReceived = false
local mcuIdReceived = false
local boardInfoReceived = false
local featuresReceived = false
local getApiVersion, getVtxTables, getMCUId, getBoardInfo, getFeaturesInfo
local returnTable = { f = nil, t = "" }

local function init()
    if getRSSI() == 0 then
        returnTable.t = "Waiting for connection"
    elseif not apiVersionReceived then
        getApiVersion = getApiVersion or assert(loadScript("api_version.lua"))()
        returnTable.t = getApiVersion.t
        apiVersionReceived = getApiVersion.f()
        if apiVersionReceived then
            getApiVersion = nil
            collectgarbage()
        end
    elseif not mcuIdReceived and apiVersion >= 1.42 then
        getMCUId = getMCUId or assert(loadScript("mcu_id.lua"))()
        returnTable.t = getMCUId.t
        mcuIdReceived = getMCUId.f()
        if mcuIdReceived then
            getMCUId = nil
            local f = loadScript("VTX_TABLES/" .. mcuId .. ".lua")
            if f then
                local table = f()
                if table then
                    vtxTablesReceived = true
                    features.vtx = 0 < table.frequenciesPerBand
                    f = nil
                    table = nil
                end
            end
            collectgarbage()
            f = loadScript("BOARD_INFO/"..mcuId..".lua")
            if f and f() then
                boardInfoReceived = true
                f = nil
            end
            collectgarbage()
        end
    elseif not vtxTablesReceived and apiVersion >= 1.42 then
        getVtxTables = getVtxTables or assert(loadScript("vtx_tables.lua"))()
        returnTable.t = getVtxTables.t
        vtxTablesReceived = getVtxTables.f()
        if vtxTablesReceived then
            getVtxTables = nil
            collectgarbage()
        end
    elseif not boardInfoReceived and apiVersion >= 1.44 then
        getBoardInfo = getBoardInfo or assert(loadScript("board_info.lua"))()
        returnTable.t = getBoardInfo.t
        boardInfoReceived = getBoardInfo.f()
        if boardInfoReceived then
            getBoardInfo = nil
            collectgarbage()
        end
    elseif not featuresReceived and apiVersion >= 1.41 then
        getFeaturesInfo = getFeaturesInfo or assert(loadScript("features_info.lua"))()
        returnTable.t = getFeaturesInfo.t
        featuresReceived = getFeaturesInfo.f()
        if featuresReceived then
            getFeaturesInfo = nil
            collectgarbage()
        end
    else
        return true
    end
    return apiVersionReceived and vtxTablesReceived and mcuId and boardInfoReceived and featuresReceived
end

returnTable.f = init

return returnTable
