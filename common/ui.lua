-- load msp.lua
assert(loadScript("/SCRIPTS/BF/msp_sp.lua"))()

-- global variables for pit mode state
PIT_MODE_STATE_DISARMED = 1
PIT_MODE_STATE_ARMED = 2
PIT_MODE_STATE_CONSUMED = 3

gPitModeState = PIT_MODE_STATE_CONSUMED

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

local gState = PAGE_DISPLAY

local PAGE_PIDS = 1
local PAGE_RATES = 2
local PAGE_VTX = 3

local currentPage = PAGE_PIDS
local currentLine = 1
local saveTS = 0
local saveTimeout = 0
local saveRetries = 0
local saveMaxRetries = 0
local lastRSSI = 0

backgroundFill = backgroundFill or ERASE
foregroundColor = foregroundColor or SOLID
globalTextOptions = globalTextOptions or 0

local function savePage(page)
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

local function saveCurrentPage()
   savePage(SetupPages[currentPage])
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

   { t = "Save Page",
     f = saveCurrentPage },

   { t = "Reload",
     f = invalidatePages }
}

local telemetryScreenActive = false
local menuActive = false

local function processMspReply(cmd,rx_buf)

   if cmd == nil or rx_buf == nil then
      return
   end

   local page = nil

   -- find the page that initiated the command
   for i=1,#(SetupPages) do
      local testPage = SetupPages[i]
      if testPage.read == cmd or testPage.write == cmd then
         page = testPage
         break
      end
   end

   if page == nil then
      return
   end

   -- ignore replies to write requests for now
   if cmd == page.write and cmd ~= MSP_VTX_SET_CONFIG then
      mspSendRequest(MSP_EEPROM_WRITE,{})
      return
   end

   if cmd == MSP_EEPROM_WRITE or cmd == MSP_VTX_SET_CONFIG then
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

local function drawScreen(page)

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

local function background_ui()

   local currentRSSI = getValue("RSSI")
   -- if RSSI went from none to some, invalidate pages
   if  currentRSSI ~= 0 and lastRSSI == 0 then
      invalidatePages()
   end
   lastRSSI = currentRSSI

   if (gState == PAGE_SAVING) and (saveTS + saveTimeout < getTime()) then
      if saveRetries < saveMaxRetries then
         saveCurrentPage()
      else
         -- max retries reached
         gState = PAGE_DISPLAY
         invalidatePages()
      end
   end

   if gPitModeState == PIT_MODE_STATE_ARMED then
      local vtxPage = SetupPages[PAGE_VTX]

      -- if we have valid vtx values, use those
      if vtxPage.values and vtxPage.values[5] == 1 then
         vtxPage.values[5] = 0
         savePage(vtxPage)
      elseif not vtxPage.values then
         -- set invalid values except for clearing pit mode
         vtxPage.values = { 99, 99, 99, 99, 0}
         savePage(vtxPage)
         vtxPage.values = nil
      end

      gPitModeState = PIT_MODE_STATE_CONSUMED
   end

   -- process send queue
   mspProcessTxQ()
   processMspReply(mspPollReply())
   return 0
end

local killEnterBreak = 0

local function run_ui(event)

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

   if not page.values then
      -- request values
      requestPage(page)
   end

   -- draw screen
   lcd.clear()
   if TEXT_BGCOLOR then
      lcd.drawFilledRectangle(0, 0, LCD_W, LCD_H, TEXT_BGCOLOR)
   end
   drawScreen(page)

   -- do we have valid telemetry data?
   if getValue("RSSI") == 0 then
      lcd.drawText(NoTelem[1],NoTelem[2],NoTelem[3],NoTelem[4])
   end

   if gState == MENU_DISP then
      drawMenu()
   elseif gState == PAGE_SAVING then
      lcd.drawFilledRectangle(SaveBox.x,SaveBox.y,SaveBox.w,SaveBox.h,backgroundFill)
      lcd.drawRectangle(SaveBox.x,SaveBox.y,SaveBox.w,SaveBox.h,SOLID)
      lcd.drawText(SaveBox.x+SaveBox.x_offset,SaveBox.y+SaveBox.h_offset,"Saving...",DBLSIZE + BLINK + (globalTextOptions))
   end

   return 0
end

local freqLookup = {
    { 5865, 5845, 5825, 5805, 5785, 5765, 5745, 5725 }, -- Boscam A
    { 5733, 5752, 5771, 5790, 5809, 5828, 5847, 5866 }, -- Boscam B
    { 5705, 5685, 5665, 5645, 5885, 5905, 5925, 5945 }, -- Boscam E
    { 5740, 5760, 5780, 5800, 5820, 5840, 5860, 5880 }, -- FatShark
    { 5658, 5695, 5732, 5769, 5806, 5843, 5880, 5917 }, -- RaceBand
}

local function updateVTXFreq(page)
   page.values["f"] = freqLookup[page.values[2]][page.values[3]]
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


   if page.values and page.values[2] and page.values[3] then
      if page.values[2] > 0 and page.values[3] > 0 then
         updateVTXFreq(page)
      else
         page.values = nil
      end
   end
end

local function getWriteValuesVTX(values)
   local channel = (values[2]-1)*8 + values[3]-1
   return { bit32.band(channel,0xFF), bit32.rshift(channel,8), values[4], values[5] }
end

SetupPages[PAGE_PIDS].read  = MSP_PID
SetupPages[PAGE_PIDS].write = MSP_SET_PID

SetupPages[PAGE_RATES].read  = MSP_RC_TUNING
SetupPages[PAGE_RATES].write = MSP_SET_RC_TUNING

SetupPages[PAGE_VTX].read           = MSP_VTX_CONFIG
SetupPages[PAGE_VTX].write          = MSP_VTX_SET_CONFIG
SetupPages[PAGE_VTX].postRead       = postReadVTX
SetupPages[PAGE_VTX].getWriteValues = getWriteValuesVTX
SetupPages[PAGE_VTX].saveMaxRetries = 0
SetupPages[PAGE_VTX].saveTimeout    = 300 -- 3s

SetupPages[PAGE_VTX].fields[1].upd = updateVTXFreq
SetupPages[PAGE_VTX].fields[2].upd = updateVTXFreq

return run_ui, background_ui
