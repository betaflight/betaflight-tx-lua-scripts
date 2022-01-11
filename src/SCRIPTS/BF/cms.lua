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
    if stickMovement() then
        cms.synced = false
        lastMenuEventTime = getTime()
    end
    cms.update()
    if (cms.menuOpen == false) then
        cms.open()
    end
    if (event == radio.refresh.event) or (lastMenuEventTime + INTERVAL < getTime() and not cms.synced) then
        cms.refresh()
    end
    if (event == EVT_VIRTUAL_EXIT) then
        cms.close()
        return 1
    end
    return 0
end

return { init=init, run=run }
