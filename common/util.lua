function clipValue(val, min, max)
   if val < min then
      val = min
   elseif val > max then
      val = max
   end

   return val
end


local lastDebugPrintText = ""

--- For debugging: Draws the last logged string to the screen at a predefined location.
function drawLastDebugPrintText()
   if (lastDebugPrintText ~= nil) then
      lcd.drawText(10, 56, lastDebugPrintText, SMLSIZE)
   end
end

--- For debugging: Logs the given string to the console, as well as stores it and draws it on-screen.
-- @param str 
function debugPrint(str)
   print(str)
   lastDebugPrintText = str
   drawLastDebugPrintText(str)
end

--- Adds the given value at the given index if the index is not nil, to the given table.
-- @param table
-- @param key table key, if nil, will not be added
-- @param value
--
function addToTableIfKeyNotNil(table, key, value)
--   print("Table", key, value)
   if (key ~= nil) then
      table[key] = value
   end
end

--- The time that the last menu LONG keypress was handled
local lastHandledMenuLong = 0

--- For how long to ignore EVT_MENU_BREAK after a handled EVT_MENU_LONG, in 10ms ticks
local IGNORE_MENU_BREAK_AFTER_MENU_LONG_DURATION = 1000 / 10 -- 1000 millis is 1000 "10ms ticks"

--- @return whether an EVT_MENU_BREAK should be ignored since an EVT_MENU_LONG was recently handled.
function shouldIgnoreMenuBreak()
   return getTime() - lastHandledMenuLong < IGNORE_MENU_BREAK_AFTER_MENU_LONG_DURATION
end

--- Records that EVT_MENU_LONG was just handled.
function handledMenuLong()
   lastHandledMenuLong = getTime()
end


