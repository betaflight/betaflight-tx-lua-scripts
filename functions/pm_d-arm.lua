local function run()
  if gPitModeState then
    gPitModeState = PIT_MODE_STATE_DISARMED
  end
end

return { run=run }
