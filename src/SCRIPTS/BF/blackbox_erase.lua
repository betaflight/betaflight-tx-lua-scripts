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
-- How long "Erase status unknown" stays up before returning to the page.
local UNKNOWN_HOLD = 300
local unknownUntil = nil

local returnTable = { f = nil, t = "Erasing blackbox flash..." }

local SUMMARY_BYTES = 13 -- flags (U8), sectors, total, used (U32 each)

local function processMspReply(cmd, payload, err)
    -- Only usable replies count as the FC being there: a refused or truncated
    -- summary must neither keep the timeout from expiring nor be decoded.
    local usableSummary = cmd == MSP_DATAFLASH_SUMMARY and not err and payload and #payload >= SUMMARY_BYTES
    if (cmd == MSP_DATAFLASH_ERASE and not err) or usableSummary then
        lastReplyTS = getTime()
    end
    if cmd == MSP_DATAFLASH_ERASE then
        -- A refusal ends here; the page re-read afterwards shows what is left.
        done = err and true or false
        eraseAcked = not err
    elseif usableSummary and eraseAcked then
        local ready = bit32.btest(payload[1], FLAG_READY)
        local used = payload[10] + payload[11] * 256 + payload[12] * 65536 + payload[13] * 16777216
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
    if unknownUntil then
        done = unknownUntil < getTime()
        return done
    end
    if not done and lastReplyTS + NO_REPLY_TIMEOUT < getTime() then
        -- Give up and say so. Drop any request still queued so an erase the
        -- link never delivered cannot go out after the user has left; the
        -- page re-read afterwards shows the flash once the FC answers.
        mspClearTxQ()
        returnTable.t = "Erase status unknown"
        unknownUntil = getTime() + UNKNOWN_HOLD
        return false
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
