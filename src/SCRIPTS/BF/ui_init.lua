local apiVersionReceived = false
local mcuIdReceived = false
local featuresReceived = false
local getApiVersion, getMCUId, getFeaturesInfo
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
    return apiVersionReceived and mcuId and featuresReceived
end

returnTable.f = init

return returnTable
