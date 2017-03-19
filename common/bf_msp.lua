--- BF MSP commands, see msp/msp_protocol.h in Betaflight
BF_MSP_COMMANDS = {
   -- getter
   MSP_RC_TUNING = 111,
   MSP_PID = 112,

   -- setter
   MSP_SET_PID = 202,
   MSP_SET_RC_TUNING = 204,

   -- BF specials
   MSP_PID_ADVANCED = 94,
   MSP_SET_PID_ADVANCED = 95,
   MSP_VTX_CONFIG = 88,
   MSP_VTX_SET_CONFIG = 89,

   -- camera OSD control
   MSP_CAMERA_CONTROL = 98,

   MSP_EEPROM_WRITE = 250
}
