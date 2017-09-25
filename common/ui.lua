-- load msp.lua
assert(loadScript("/SCRIPTS/BF/msp_sp.lua"))()

-- getter
local MSP_RC_TUNING     = 111
local MSP_PID           = 112

-- setter
local MSP_SET_PID       = 202
local MSP_SET_RC_TUNING = 204

-- BF specials
local MSP_PID_ADVANCED     = 94
local MSP_SET_PID_ADVANCED = 95
local MSP_VTX_CONFIG       = 88
local MSP_VTX_SET_CONFIG   = 89

local MSP_EEPROM_WRITE = 250

local REQ_TIMEOUT = 80 -- 800ms request timeout

--local PAGE_REFRESH = 1
local PAGE_DISPLAY = 2
local EDITING      = 3
local PAGE_SAVING  = 4
local MENU_DISP    = 5

local NUM_BANDS = 5
local NUM_CHANS = 8

local gState = PAGE_DISPLAY

local currentPage = 1
local currentLine = 1
local saveTS = 0
local saveTimeout = 0
local saveRetries = 0
local saveMaxRetries = 0

backgroundFill = backgroundFill or ERASE
foregroundColor = foregroundColor or SOLID
globalTextOptions = globalTextOptions or 0

local function saveSettings(new)
   local page = SetupPages[currentPage]
   if page.values then
      if page.getWriteValues then
         mspSendRequest(page.write,page.getWriteValues(page.values))
      else
         mspSendRequest(page.write,page.values)
      end
      saveTS = getTime()
      if gState == PAGE_SAVING then
         saveRetries = saveRetries + 1
      else
         gState = PAGE_SAVING
         saveRetries = 0
         saveMaxRetries = page.saveMaxRetries or 2 -- default 2
         saveTimeout = page.saveTimeout or 150     -- default 1.5s
      end
   end
end

local function invalidatePages()
   for i=1,#(SetupPages) do
      local page = SetupPages[i]
      page.values = nil
   end
   gState = PAGE_DISPLAY
   saveTS = 0
end

local menuList = {

   { t = "save page",
     f = saveSettings },

   { t = "reload",
     f = invalidatePages }
}

local telemetryScreenActive = false
local menuActive = false

local function processMspReply(cmd,rx_buf)

   if cmd == nil or rx_buf == nil then
      return
   end

   local page = SetupPages[currentPage]

   -- ignore replies to write requests for now
   if cmd == page.write then
      if cmd ~= MSP_VTX_SET_CONFIG then
         mspSendRequest(MSP_EEPROM_WRITE,{})
      end
      return
   end

   if cmd == MSP_EEPROM_WRITE then
      gState = PAGE_DISPLAY
      page.values = nil
      saveTS = 0
      return
   end
   
   if cmd ~= page.read then
      return
   end

   if #(rx_buf) > 0 then
      page.values = {}
      for i=1,#(rx_buf) do
         page.values[i] = rx_buf[i]
      end

      if page.postRead ~= nil then
         page.postRead(page)
      end
   end
end
   
local function MaxLines()
   return #(SetupPages[currentPage].fields)
end

local function incPage(inc)
   currentPage = currentPage + inc
   if currentPage > #(SetupPages) then
      currentPage = 1
   elseif currentPage < 1 then
      currentPage = #(SetupPages)
   end
   currentLine = 1
end

local function incLine(inc)
   currentLine = currentLine + inc
   if currentLine > MaxLines() then
      currentLine = 1
   elseif currentLine < 1 then
      currentLine = MaxLines()
   end
end

local function incMenu(inc)
   menuActive = menuActive + inc
   if menuActive > #(menuList) then
      menuActive = 1
   elseif menuActive < 1 then
      menuActive = #(menuList)
   end
end

local function requestPage(page)
   if page.read and ((page.reqTS == nil) or (page.reqTS + REQ_TIMEOUT <= getTime())) then
      page.reqTS = getTime()
      mspSendRequest(page.read,{})
   end
end

function drawScreenTitle(screen_title)
   lcd.drawFilledRectangle(0, 0, LCD_W, 10)
   lcd.drawText(1,1,screen_title,INVERS)
end

local function drawScreen(page,page_locked)

   local screen_title = page.title

   drawScreenTitle("Betaflight / "..screen_title)

   for i=1,#(page.text) do
      local f = page.text[i]
      if f.to == nil then
         lcd.drawText(f.x, f.y, f.t, globalTextOptions)
      else
         lcd.drawText(f.x, f.y, f.t, f.to)
      end
   end
   
   for i=1,#(page.fields) do
      local f = page.fields[i]

      local text_options = globalTextOptions
      if i == currentLine then
         text_options = INVERS
         if gState == EDITING then
            text_options = text_options + BLINK
         end
      end

      local spacing = 20

      if f.t ~= nil then
         lcd.drawText(f.x, f.y, f.t .. ":", globalTextOptions)

         -- draw some value
         if f.sp ~= nil then
            spacing = f.sp
         end
      else
         spacing = 0
      end

      local idx = f.i or i
      if page.values and page.values[idx] then
         local val = page.values[idx]
         if f.table and f.table[page.values[idx]] then
            val = f.table[page.values[idx]]
         end
         lcd.drawText(f.x + spacing, f.y, val, text_options)
      else
         lcd.drawText(f.x + spacing, f.y, "---", text_options)
      end
   end
end

local function clipValue(val,min,max)
   if val < min then
      val = min
   elseif val > max then
      val = max
   end

   return val
end

local function getCurrentField()
   local page = SetupPages[currentPage]
   return page.fields[currentLine]
end

local function incValue(inc)
   local page = SetupPages[currentPage]
   local field = page.fields[currentLine]
   local idx = field.i or currentLine
   page.values[idx] = clipValue(page.values[idx] + inc, field.min or 0, field.max or 255)
   if field.upd then field.upd(page) end
end

local function drawMenu()
   local x = MenuBox.x
   local y = MenuBox.y
   local w = MenuBox.w
   local h_line = MenuBox.h_line
   local h_offset = MenuBox.h_offset
   local h = #(menuList) * h_line + h_offset*2

   lcd.drawFilledRectangle(x,y,w,h,backgroundFill)
   lcd.drawRectangle(x,y,w-1,h-1,foregroundColor)
   lcd.drawText(x+h_line/2,y+h_offset,"Menu:",globalTextOptions)

   for i,e in ipairs(menuList) do
      local text_options = globalTextOptions
      if menuActive == i then
         text_options = text_options + INVERS
      end
      lcd.drawText(x+MenuBox.x_offset,y+(i-1)*h_line+h_offset,e.t,text_options)
   end
end

local lastRunTS = 0
local killEnterBreak = 0

local function run_ui(event)

   local now = getTime()

   -- if lastRunTS old than 500ms
   if lastRunTS + 50 < now then
      invalidatePages()
   end
   lastRunTS = now

   if (gState == PAGE_SAVING) and (saveTS + saveTimeout < now) then
      if saveRetries < saveMaxRetries then
         saveSettings()
      else
         -- max retries reached
         gState = PAGE_DISPLAY
         invalidatePages()
      end
   end

   -- process send queue
   mspProcessTxQ()

   -- navigation
   if (event == EVT_MENU_LONG) then -- Taranis QX7 / X9
      menuActive = 1
      gState = MENU_DISP

   elseif EVT_PAGEUP_FIRST and (event == EVT_ENTER_LONG) then -- Horus
      menuActive = 1
      killEnterBreak = 1
      gState = MENU_DISP

   -- menu is currently displayed
   elseif gState == MENU_DISP then
      if event == EVT_EXIT_BREAK then
         gState = PAGE_DISPLAY
      elseif event == EVT_PLUS_BREAK or event == EVT_ROT_LEFT then
         incMenu(-1)
      elseif event == EVT_MINUS_BREAK or event == EVT_ROT_RIGHT then
         incMenu(1)
      elseif event == EVT_ENTER_BREAK then
         if killEnterBreak == 1 then
            killEnterBreak = 0
         else
            gState = PAGE_DISPLAY
            menuList[menuActive].f()
         end
      end
   -- normal page viewing
   elseif gState <= PAGE_DISPLAY then
      if event == EVT_PAGEUP_FIRST then
         incPage(-1)
      elseif event == EVT_MENU_BREAK or event == EVT_PAGEDN_FIRST then
         incPage(1)
      elseif event == EVT_PLUS_BREAK or event == EVT_ROT_LEFT then
         incLine(-1)
      elseif event == EVT_MINUS_BREAK or event == EVT_ROT_RIGHT then
         incLine(1)
      elseif event == EVT_ENTER_BREAK then
         local page = SetupPages[currentPage]
         local field = page.fields[currentLine]
         local idx = field.i or currentLine
         if page.values and page.values[idx] and (field.ro ~= true) then
            gState = EDITING
         end
      end
   -- editing value
   elseif gState == EDITING then
      if (event == EVT_EXIT_BREAK) or (event == EVT_ENTER_BREAK) then
         gState = PAGE_DISPLAY
      elseif event == EVT_PLUS_FIRST or event == EVT_PLUS_REPT or event == EVT_ROT_RIGHT then
         incValue(1)
      elseif event == EVT_MINUS_FIRST or event == EVT_MINUS_REPT or event == EVT_ROT_LEFT then
         incValue(-1)
      end
   end

   local page = SetupPages[currentPage]
   local page_locked = false

   if not page.values then
      -- request values
      requestPage(page)
      page_locked = true
   end

   -- draw screen
   lcd.clear()
   if TEXT_BGCOLOR then
      lcd.drawFilledRectangle(0, 0, LCD_W, LCD_H, TEXT_BGCOLOR)
   end
   drawScreen(page,page_locked)
   
   -- do we have valid telemetry data?
   if getValue("RSSI") == 0 then
      -- No!
      lcd.drawText(NoTelem[1],NoTelem[2],NoTelem[3],NoTelem[4])
      --invalidatePages()
   end

   if gState == MENU_DISP then
      drawMenu()
   elseif gState == PAGE_SAVING then
      lcd.drawFilledRectangle(SaveBox.x,SaveBox.y,SaveBox.w,SaveBox.h,backgroundFill)
      lcd.drawRectangle(SaveBox.x,SaveBox.y,SaveBox.w,SaveBox.h,SOLID)
      lcd.drawText(SaveBox.x+SaveBox.x_offset,SaveBox.y+SaveBox.h_offset,"Saving...",DBLSIZE + BLINK + (globalTextOptions))
   end

   processMspReply(mspPollReply())
   return 0
end

local freqLookup = {
    { 5865, 5845, 5825, 5805, 5785, 5765, 5745, 5725 }, -- Boscam A
    { 5733, 5752, 5771, 5790, 5809, 5828, 5847, 5866 }, -- Boscam B
    { 5705, 5685, 5665, 5645, 5885, 5905, 5925, 5945 }, -- Boscam E
    { 5740, 5760, 5780, 5800, 5820, 5840, 5860, 5880 }, -- FatShark
    { 5658, 5695, 5732, 5769, 5806, 5843, 5880, 5917 }, -- RaceBand
}

local lastFreqVal = 0
local lastFreqUpdTS = 0
local freqModCntr = 0

local function updateVTXBandChan(page)
   if page.values[2] > 0 then   -- band != 0
      page.values["f"] = freqLookup[page.values[2]][page.values[3]]
   else   -- band == 0; set freq via channel*100
      page.values["f"] = 5100 + (math.floor(page.values[3]) * 100)
   end
  lastFreqVal = page.values["f"]   -- keep track of displayed freq
end

local function updateVTXFreq(page)
   local newFreq = page.values["f"]
   if page.values[2] == 0 then   -- band == 0
      local now = getTime()   -- track rate of change for possible mod speedup
      if newFreq ~= lastFreqVal and now < lastFreqUpdTS + 15 then
         freqModCntr = freqModCntr + (15-(lastFreqUpdTS-now))   -- increase counter for mod speedup
      else
         freqModCntr = 0   -- no mod speedup
      end
      if freqModCntr > 65 then  -- rate is fast enough; do mod speedup
         if newFreq > lastFreqVal then
            newFreq = clipValue(newFreq + math.floor(freqModCntr/65), G_MIN_FREQ_VAL, G_MAX_FREQ_VAL)
         else
            newFreq = clipValue(newFreq - math.floor(freqModCntr/65), G_MIN_FREQ_VAL, G_MAX_FREQ_VAL)
         end
         page.values["f"] = newFreq
      end
                        -- set channel value via freq/100:
      page.values[3] = clipValue(math.floor((newFreq - 5100) / 100), 1, 8)
      lastFreqUpdTS = now
      lastFreqVal = newFreq            -- keep track of displayed freq
   else   -- band != 0; find closest freq in table that is above/below dialed freq
      if newFreq ~= lastFreqVal then
         local startBand
         local endBand
         local incFlag       -- freq increasing or decreasing
         if newFreq > lastFreqVal then
            incFlag = 1
            startBand = 1
            endBand = NUM_BANDS
         else
            incFlag = -1
            startBand = NUM_BANDS
            endBand = 1
         end
         local curBand = page.values[2]
         local curChan = page.values[3]
         local selBand = 0
         local selChan = 0
         local selFreq = 0
         local diffVal = 9999
         local fVal
              -- need to scan bands in same "direction" as 'incFlag'
              --  so same-freq selections will be handled properly (F8 & R7)
         for band=startBand,endBand,incFlag do
            for chan=1,NUM_CHANS do
               if band ~= curBand or chan ~= curChan then   -- don't reselect same band/chan
                  fVal = freqLookup[band][chan]
                  if incFlag > 0 then
                     if fVal >= lastFreqVal and fVal - lastFreqVal < diffVal then
                             -- if same freq then only select if "next" band:
                        if fVal ~= lastFreqVal or band > curBand then
                           selBand = band
                           selChan = chan
                           selFreq = fVal
                           diffVal = fVal - lastFreqVal
                        end
                     end
                  else
                     if fVal <= lastFreqVal and lastFreqVal - fVal < diffVal then
                             -- if same freq then only select if "previous" band:
                        if fVal ~= lastFreqVal or band < curBand then
                           selBand = band
                           selChan = chan
                           selFreq = fVal
                           diffVal = lastFreqVal - fVal
                        end
                     end
                  end
               end
            end
         end
         if selFreq > 0 then
            page.values["f"] = selFreq      -- using new freq from table
            page.values[2] = selBand
            page.values[3] = selChan
            lastFreqVal = selFreq           -- keep track of displayed freq
         else
            page.values["f"] = lastFreqVal  -- if no match then revert freq
         end
      end
   end
end

local function postReadVTX(page)
   if page.values[1] == 3 then -- SmartAudio
      page.fields[3].table = { 25, 200, 500, 800 }
      page.fields[3].max = 4
   elseif page.values[1] == 4 then -- Tramp
      page.fields[3].table = { 25, 100, 200, 400, 600 }
      page.fields[3].max = 5
   else
      -- TODO: print label on unavailable (0xFF) vs. unsupported (0)
      --page.values = nil
   end


   if page.values then
      local rfreq
      if page.values[7] and page.values[7] > 0 then
         rfreq = page.values[6] + (page.values[7] * 256)
      else
         rfreq = 0
      end
      if page.values[2] and page.values[2] > 0 then   -- band != 0
         if page.values[3] and page.values[3] > 0 then
            updateVTXBandChan(page)
            if rfreq == 0 then            -- if user freq not supported then
               page.fields[1].min = 1     -- don't allow 'U' band
            end
         else
            page.values = nil
         end
      else   -- band == 0
         if rfreq > 0 then
            page.values["f"] = rfreq
            lastFreqVal = rfreq           -- keep track of displayed freq
            updateVTXFreq(page)
            page.fields[1].min = 0        -- make sure 'U' band allowed
         else
            page.values = nil
         end
      end
   end
end

local function getWriteValuesVTX(values)
   local channel
   if values[2] > 0 then   -- band != 0
      channel = (values[2]-1)*8 + values[3]-1
   else   -- band == 0
      channel = values["f"]
   end
   return { bit32.band(channel,0xFF), bit32.rshift(channel,8), values[4], values[5] }
end

SetupPages[1].read  = MSP_PID
SetupPages[1].write = MSP_SET_PID

SetupPages[2].read  = MSP_RC_TUNING
SetupPages[2].write = MSP_SET_RC_TUNING 

SetupPages[3].read           = MSP_VTX_CONFIG
SetupPages[3].write          = MSP_VTX_SET_CONFIG
SetupPages[3].postRead       = postReadVTX
SetupPages[3].getWriteValues = getWriteValuesVTX
SetupPages[3].saveMaxRetries = 0
SetupPages[3].saveTimeout    = 300 -- 3s

SetupPages[3].fields[1].upd = updateVTXBandChan
SetupPages[3].fields[2].upd = updateVTXBandChan
SetupPages[3].fields[6].upd = updateVTXFreq

return run_ui
