local MSP_DATAFLASH_SUMMARY = 70
local MSP_DATAFLASH_ERASE = 72

local FLAG_READY = 1

-- An erase that never starts (e.g. blackbox_device is not FLASH) leaves the
-- flash ready with the same contents; stop polling after this many replies.
local MAX_IDLE_POLLS = 10

local eraseAcked = false
local sawBusy = false
local idlePolls = 0
local done = false
local lastRunTS = 0
local INTERVAL = 50
-- Resending the erase only when no ack has come back for a while keeps a slow
-- link from starting it twice.
local ERASE_RETRY = 300
local eraseSentTS = nil
-- Give up when the FC has gone quiet for this long (lost telemetry), so the
-- init screen cannot hang. A chip erase can take minutes, but the FC keeps
-- answering the summary polls while it runs, so this only counts silence.
local NO_REPLY_TIMEOUT = 1000
local lastReplyTS = nil

local returnTable = { f = nil, t = "Erasing blackbox flash..." }

local function processMspReply(cmd, payload, err)
    -- Only usable replies count as the FC being there; a refused summary
    -- must not keep the timeout from expiring.
    if (cmd == MSP_DATAFLASH_ERASE or cmd == MSP_DATAFLASH_SUMMARY) and not err then
        lastReplyTS = getTime()
    end
    if cmd == MSP_DATAFLASH_ERASE then
        -- A refusal ends here; the page re-read afterwards shows what is left.
        done = err and true or false
        eraseAcked = not err
    elseif cmd == MSP_DATAFLASH_SUMMARY and eraseAcked and payload and not err then
        local ready = bit32.btest(payload[1] or 0, FLAG_READY)
        local used = (payload[10] or 0) + (payload[11] or 0) * 256 + (payload[12] or 0) * 65536 + (payload[13] or 0) * 16777216
        if not ready then
            sawBusy = true
        elseif used == 0 or sawBusy then
            done = true
        else
            idlePolls = idlePolls + 1
            done = idlePolls >= MAX_IDLE_POLLS
        end
    end
end

local function erase()
    lastReplyTS = lastReplyTS or getTime()
    if lastReplyTS + NO_REPLY_TIMEOUT < getTime() then
        -- Erase status unknown; the page re-read afterwards shows what is on
        -- the flash. Any request still queued is drained by the next frame's
        -- mspProcessTxQ, and its late reply is ignored by the page.
        done = true
    end
    if not done and lastRunTS + INTERVAL < getTime() then
        lastRunTS = getTime()
        if not eraseAcked then
            if not eraseSentTS or eraseSentTS + ERASE_RETRY < getTime() then
                eraseSentTS = getTime()
                protocol.mspRead(MSP_DATAFLASH_ERASE)
            end
        else
            protocol.mspRead(MSP_DATAFLASH_SUMMARY)
        end
    end
    mspProcessTxQ()
    processMspReply(mspPollReply())
    return done
end

returnTable.f = erase

return returnTable
