local lastMenuEventTime = 0
local INTERVAL = 80

local function init()
    cms.init(radio)
end

local function stickMovement()
    local threshold = 30
    return math.abs(getValue('ele')) > threshold or math.abs(getValue('ail')) > threshold or math.abs(getValue('rud')) > threshold
end

local function run(event)
    cms.update()
    if cms.menuOpen == false then
        cms.open()
    end
    if event == radio.refresh.event then
        cms.synced = false
        lastMenuEventTime = 0
    elseif stickMovement() then
        cms.synced = false
        lastMenuEventTime = getTime()
    elseif event == EVT_VIRTUAL_EXIT then
        cms.close()
        return 1
    end
    if lastMenuEventTime + INTERVAL < getTime() and not cms.synced then
        lastMenuEventTime = getTime()
        cms.refresh()
    end
    return 0
end

return { init=init, run=run }
