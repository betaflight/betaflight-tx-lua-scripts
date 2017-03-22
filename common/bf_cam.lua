assert(loadScript("/SCRIPTS/BF/bf_msp.lua"))()
assert(loadScript("/SCRIPTS/BF/util.lua"))()

--- a table of MSP camera OSD commands.
CAM_OSD_COMMANDS = {
   ENTER = 0,
   LEFT = 1,
   UP = 2,
   RIGHT = 3,
   DOWN = 4
}

--- @return a table of supported key press commands to MSP camera OSD commands.
local function initializeCamOsdCommandValuesTable()
   table = {}

   -- right
   addToTableIfKeyNotNil(table, EVT_PLUS_FIRST, CAM_OSD_COMMANDS.RIGHT)       -- Taranis
   addToTableIfKeyNotNil(table, EVT_PLUS_REPT, CAM_OSD_COMMANDS.RIGHT)        -- Horus
   addToTableIfKeyNotNil(table, EVT_ROT_RIGHT, CAM_OSD_COMMANDS.RIGHT)        -- Horus
   -- left
   addToTableIfKeyNotNil(table, EVT_MINUS_FIRST, CAM_OSD_COMMANDS.LEFT)       -- Taranis
   addToTableIfKeyNotNil(table, EVT_MINUS_REPT, CAM_OSD_COMMANDS.LEFT)        -- Taranis
   addToTableIfKeyNotNil(table, EVT_ROT_LEFT, CAM_OSD_COMMANDS.LEFT)          -- Horus
   -- down
   addToTableIfKeyNotNil(table, EVT_EXIT_BREAK, CAM_OSD_COMMANDS.DOWN)
   -- up
   addToTableIfKeyNotNil(table, EVT_MENU_BREAK, CAM_OSD_COMMANDS.UP)          -- Taranis
   -- enter
   addToTableIfKeyNotNil(table, EVT_ENTER_BREAK, CAM_OSD_COMMANDS.ENTER)

   return table
end

--- Key press to MSP camera OSD command translation table
local keyPressesToCamOsdCommands = initializeCamOsdCommandValuesTable()

--- Sends the given MSP camera OSD command via Smartport, if it's not nil.
-- @return whether the given command was sent.
local function sendCamOsdCommand(value)
   if (value ~= nil) then
      return mspSendRequest(BF_MSP_COMMANDS.MSP_CAMERA_CONTROL, {value})
   else
      return false
   end
end

--- Handles the given key press, by looking up the corresponding OSD command, if any.
-- Unhandled key presses will always return "false".
-- @return whether the command was handled, and a MSP camera OSD command sent as a result of the given event
function handleCamOsdKeypress(event)
   osdCommand = keyPressesToCamOsdCommands[event]
   if (osdCommand ~= nil) then
--      print("sendCamOsdCommand: ", event, osdCommand)
      sendCamOsdCommand(osdCommand)
      return true;
   else
      return false;
   end
end
