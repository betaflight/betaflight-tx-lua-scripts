-- ============================================================================
-- MSP mock for the EdgeTX simulator
-- ============================================================================
--
-- Without a flight controller attached, getRSSI() stays 0, ui_init.lua parks
-- on "Waiting for connection" and nothing past the splash can be exercised --
-- no page, no field, no edit, no save. This stands in for the FC so the
-- simulator reaches the real UI.
--
-- It patches the four globals the tool talks to, which is one layer above the
-- transport: MSP/common.lua's chunking, sequencing and CRC are bypassed rather
-- than emulated. That layer is not what any of this work touches, and faking a
-- byte stream underneath it would be a second implementation of it to keep in
-- step for no extra coverage of the UI.
--
-- bf.lua only ever loads this in the simulator -- it checks that getVersion()
-- ends in "-simu" first -- so on a radio the file just sits on the card.
--
-- Applied in two passes, because they have to straddle other loads. Calling
-- this module fakes the telemetry module, which protocols.lua probes for and
-- asserts on -- a simulated TX16S has none bound, so without this the tool dies
-- on "Telemetry protocol not supported!" before any of the rest matters. It
-- returns a second function to call once MSP/common.lua has defined the request
-- globals, which would otherwise overwrite the mocked ones.

local config = {
    -- 1.46 or above takes the single-request MSP_BUILD_INFO path for feature
    -- detection instead of three separate config reads.
    apiVersion = { 1, 46 },

    -- Build options the mocked firmware reports. VTX and OSD are off on
    -- purpose: both add a page whose first act is to download a table from the
    -- FC and write it to the SD card, which is a flow of its own rather than
    -- the settings UI. Add BUILD_OPTION.VTX here to exercise it.
    buildOptions = { "GPS" },

    -- Frames to wait before answering. 1 keeps the depth-1 request/response
    -- alternation the real link has; 0 would let a page fill in the same frame
    -- it asked, which the tool never sees on hardware.
    latency = 1,
}

local MSP_EEPROM_WRITE = 250
local MSP_REBOOT = 68
local MSP_API_VERSION = 1
local MSP_BUILD_INFO = 5
local MSP_UID = 160

local BUILD_OPTION = {
    GPS = 16412,
    OSD_SD = 16416,
    VTX = 16421,
}

-- ============================================================================
-- Canned replies
-- ============================================================================

local function buildInfoPayload()
    -- features_info.lua reads DATE(11) + TIME(8) + REVISION(7) and then takes
    -- the rest as little-endian option words. The header content is never
    -- looked at, only its length.
    local payload = {}
    for i = 1, 26 do
        payload[i] = 0x20
    end
    for i = 1, #config.buildOptions do
        local word = BUILD_OPTION[config.buildOptions[i]]
        payload[#payload + 1] = word % 256
        payload[#payload + 1] = (word - (word % 256)) / 256
    end
    return payload
end

local function uidPayload()
    -- 12 bytes, read as three little-endian words and hex-formatted into
    -- mcuId. Any fixed pattern does; a counter is easy to spot in a log.
    local payload = {}
    for i = 1, 12 do
        payload[i] = i
    end
    return payload
end

-- Everything the tool asks for that is not one of the structured replies above
-- is a settings block. Zeros keep every field inside its declared range and on
-- a key its `table` actually has, which is what a defaulted FC would send.
local function settingsPayload()
    local payload = {}
    for i = 1, 128 do
        payload[i] = 0
    end
    return payload
end

local replies = {
    [MSP_API_VERSION] = { 0, config.apiVersion[1], config.apiVersion[2] },
    [MSP_BUILD_INFO] = buildInfoPayload(),
    [MSP_UID] = uidPayload(),
    -- Acknowledgements carry no payload on real firmware.
    [MSP_EEPROM_WRITE] = {},
    [MSP_REBOOT] = {},
}

-- ============================================================================
-- The link
-- ============================================================================

local pending = nil
local countdown = 0

-- protocols.lua picks a transport by calling each push function and taking the
-- first that answers. Which one it lands on does not matter here -- only
-- mspTransport, saveTimeout and saveMaxRetries are read, and the layer that
-- would use them is replaced below -- but it has to land on one.
crossfireTelemetryPush = function()
    return true
end

-- ui_init.lua gates the whole session on this, and the renderer draws the
-- No Telemetry overlay from it.
getRSSI = function()
    return 75
end

--- Second pass. Call after MSP/common.lua, whose function definitions would
--- otherwise land on top of these.
return function()
    -- protocol.mspRead and protocol.mspWrite both funnel through
    -- mspSendRequest, so it is the only entry point requests need.
    mspSendRequest = function(cmd, _payload)
        if pending or not cmd then
            return nil
        end
        pending = cmd
        countdown = config.latency
        return false
    end

    mspProcessTxQ = function()
        return false
    end

    mspPollReply = function()
        if not pending then
            return nil
        end
        if countdown > 0 then
            countdown = countdown - 1
            return nil
        end
        local cmd = pending
        pending = nil
        return cmd, replies[cmd] or settingsPayload(), false
    end
end
