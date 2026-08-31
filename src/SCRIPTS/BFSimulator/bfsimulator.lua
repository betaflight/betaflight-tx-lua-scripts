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
-- What it does keep is the state a save changes: a write is decoded into the
-- block its page reads back, so a saved value is still there on the reload
-- afterwards. See "Writes" below.
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

    -- Build options the mocked firmware reports. VTX is off on purpose: its
    -- page's first act is to download a table from the FC and write it to the
    -- SD card, which is a flow of its own rather than the settings UI. Add
    -- BUILD_OPTION.VTX here to exercise it. OSD_SD is what puts the OSD
    -- Elements page on the menu.
    buildOptions = { "GPS", "OSD_SD" },

    -- Frames to wait before answering. 1 keeps the depth-1 request/response
    -- alternation the real link has; 0 would let a page fill in the same frame
    -- it asked, which the tool never sees on hardware.
    -- Raise to ~45 to stretch the loading states out to visible length when
    -- working on how the UI behaves while a page is in flight.
    latency = 1,
}

local MSP_EEPROM_WRITE = 250
local MSP_REBOOT = 68
local MSP_API_VERSION = 1
local MSP_BUILD_INFO = 5
local MSP_UID = 160
local MSP_STATUS_EX = 150
local MSP_RC_TUNING = 111
local MSP_OSD_CONFIG = 84

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

-- The one settings block a zeroed reply gets wrong. profiles.lua does not take
-- its PID-profile range from the page file; it derives it from the count the FC
-- reports, so a zero there means "no profiles exist" and the row renders as a
-- read-only value rather than a picker. Three is what a stock target has.
local function statusExPayload()
    local payload = settingsPayload()
    payload[14] = 3
    return payload
end

-- The block where zeros misrepresent a real FC the most. Rates are stored as
-- raw bytes a display convention divides or multiplies -- RC Rate byte 120
-- reads "1.20" -- and an all-zero reply exercises none of that, which is how a
-- renderer that floored every scaled value to an integer got past the
-- screenshots. These are the power-on defaults of a 4.5 target, byte for byte
-- as betaflight-firmware's msp.c serialises pgResetFn_controlRateProfiles:
-- rates type ACTUAL, centre sensitivity 70 deg/s, max rate 670 deg/s, expo
-- 0.00, throttle mid 0.50.
local function rcTuningPayload()
    local payload = settingsPayload()
    payload[1] = 7 -- rcRates[ROLL]
    payload[2] = 0 -- rcExpo[ROLL]
    payload[3] = 67 -- rates[ROLL]
    payload[4] = 67 -- rates[PITCH]
    payload[5] = 67 -- rates[YAW]
    payload[6] = 0 -- was tpa_rate
    payload[7] = 50 -- thrMid8
    payload[8] = 0 -- thrExpo8
    payload[9] = 0 -- was tpa_breakpoint, low byte
    payload[10] = 0 -- was tpa_breakpoint, high byte
    payload[11] = 0 -- rcExpo[YAW]
    payload[12] = 7 -- rcRates[YAW]
    payload[13] = 7 -- rcRates[PITCH]
    payload[14] = 0 -- rcExpo[PITCH]
    payload[15] = 0 -- throttle_limit_type = OFF
    payload[16] = 100 -- throttle_limit_percent
    payload[17] = 206 -- rate_limit[ROLL], 1998 little-endian
    payload[18] = 7
    payload[19] = 206 -- rate_limit[PITCH]
    payload[20] = 7
    payload[21] = 206 -- rate_limit[YAW]
    payload[22] = 7
    payload[23] = 3 -- rates_type = ACTUAL
    return payload
end

-- The OSD block has to run longer than the generic zeros: pos_osd.lua reads
-- two bytes per element up to values[164], and an element whose bytes are
-- missing is a nil that splitVal's arithmetic dies on, taking the tool and
-- the MSP pump with it. A real FC serialises every element it was built with.
-- A few elements carry distinct positions and profile bits, so moving the
-- element selector has to visibly change every widget under it.
local function osdConfigPayload()
    local payload = {}
    for i = 1, 164 do
        payload[i] = 0
    end
    payload[11] = 100 -- rssi_pos: position 100, no profiles
    payload[13] = 200 -- vbat_pos: position 200, all three profiles
    payload[14] = 0x38
    payload[63] = 44 -- pit_ang_pos: position 44, all three profiles
    payload[64] = 0x38
    return payload
end

local replies = {
    [MSP_API_VERSION] = { 0, config.apiVersion[1], config.apiVersion[2] },
    [MSP_BUILD_INFO] = buildInfoPayload(),
    [MSP_UID] = uidPayload(),
    [MSP_STATUS_EX] = statusExPayload(),
    [MSP_RC_TUNING] = rcTuningPayload(),
    [MSP_OSD_CONFIG] = osdConfigPayload(),
    -- Acknowledgements carry no payload on real firmware.
    [MSP_EEPROM_WRITE] = {},
    [MSP_REBOOT] = {},
}

-- ============================================================================
-- Writes
-- ============================================================================
--
-- A real flight controller decodes a write into its configuration and
-- serialises that configuration back on the next read. Acknowledging a write
-- and then answering the re-read with the original bytes makes every save look
-- like it silently did nothing, which is the one thing a save flow has to be
-- able to prove -- so the write has to reach the block a later read serves.

--- Most pages send back exactly the block they were given, so the payload
--- becomes the new block.
local function replaceBlock(payload)
    return payload
end

--- MSP_SET_OSD_CONFIG carries a single element -- its index, then its position
--- and profile bits -- while MSP_OSD_CONFIG answers with the whole table, two
--- bytes per element from values[11]. So this write lands in one element's
--- slot instead of replacing anything.
local function applyOsdElement(payload, block)
    local item = payload[1]
    if item and item <= 76 then
        block[11 + item * 2] = payload[2] or 0
        block[12 + item * 2] = payload[3] or 0
    end
    return block
end

--- MSP_SELECT_SETTING carries one byte: a profile index, tagged with the kind
--- of profile it selects. MSP_STATUS_EX reports the PID profile in values[11]
--- and the rate profile in values[15].
local function applyProfileSelect(payload, block)
    local value = payload[1] or 0
    if bit32.btest(value, 0x80) then
        block[15] = bit32.band(value, 0x7F)
    elseif not bit32.btest(value, 0x40) then
        block[11] = value
    end
    return block
end

--- Every write the pages issue, and where its payload goes. A write that is
--- not listed here is acknowledged without being stored: MSP_VTX_SET_CONFIG
--- reshapes its payload on the way out (a channel number the reply reports as
--- a band and a channel), and the VTX page is not reachable in the mock
--- anyway, since config.buildOptions leaves the feature out.
local writes = {
    [239] = { read = 240, apply = replaceBlock }, -- MSP_SET_ACC_TRIM
    [202] = { read = 112, apply = replaceBlock }, -- MSP_SET_PID
    [226] = { read = 136, apply = replaceBlock }, -- MSP_SET_GPS_RESCUE_PIDS
    [33] = { read = 32, apply = replaceBlock }, -- MSP_SET_BATTERY_CONFIG
    [76] = { read = 75, apply = replaceBlock }, -- MSP_SET_FAILSAFE_CONFIG
    [225] = { read = 135, apply = replaceBlock }, -- MSP_SET_GPS_RESCUE
    [95] = { read = 94, apply = replaceBlock }, -- MSP_SET_PID_ADVANCED
    [204] = { read = 111, apply = replaceBlock }, -- MSP_SET_RC_TUNING
    [45] = { read = 44, apply = replaceBlock }, -- MSP_SET_RX_CONFIG
    [93] = { read = 92, apply = replaceBlock }, -- MSP_SET_FILTER_CONFIG
    [91] = { read = 90, apply = replaceBlock }, -- MSP_SET_ADVANCED_CONFIG
    [141] = { read = 140, apply = replaceBlock }, -- MSP_SET_SIMPLIFIED_TUNING
    [85] = { read = 84, apply = applyOsdElement }, -- MSP_SET_OSD_CONFIG
    [210] = { read = 150, apply = applyProfileSelect }, -- MSP_SELECT_SETTING
}

--- The payload as the flight controller would have received it. Page.values
--- holds a field's value in its first slot and shifted copies in the rest, and
--- it is MSP/common.lua that bands each one to a byte on its way into the
--- frame -- a layer this mock replaces, so it does that masking itself.
local function receivedBytes(payload)
    local bytes = {}
    for i = 1, #payload do
        bytes[i] = bit32.band(payload[i], 0xFF)
    end
    return bytes
end

-- ============================================================================
-- The link
-- ============================================================================

--- Replies are copied on the way out because a page keeps the table it was
--- given as its Page.values and edits it in place. Handing out the stored
--- block itself would make an edit stick without a save -- and make a save
--- impossible to tell from one.
local function replyTo(cmd)
    if writes[cmd] then
        return {}
    end
    local block = replies[cmd] or settingsPayload()
    local copy = {}
    for i = 1, #block do
        copy[i] = block[i]
    end
    return copy
end

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
    mspSendRequest = function(cmd, payload)
        if pending or not cmd then
            return nil
        end
        local write = writes[cmd]
        if write and payload then
            local block = replies[write.read] or settingsPayload()
            replies[write.read] = write.apply(receivedBytes(payload), block)
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
        return cmd, replyTo(cmd), false
    end
end
