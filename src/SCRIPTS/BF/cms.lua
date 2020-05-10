lastMenuEventTime = 0

local function init()
    cms.init(radio)
end

local function run(event)
    lastMenuEventTime = getTime()
    cms.update()
    if (cms.menuOpen == false) then
        cms.open()
    end
    if (event == radio.refresh.event) then
        cms.refresh()
    end
    if (event == EVT_VIRTUAL_EXIT) then
        cms.close()
        return 1
    end
    return 0
end

return { init=init, run=run }
