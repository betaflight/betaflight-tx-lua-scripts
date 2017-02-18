local function run()
  if gPitModeState and gPitModeState == PIT_MODE_STATE_DISARMED then
    gPitModeState = PIT_MODE_STATE_ARMED
  end
end

return { run=run }
