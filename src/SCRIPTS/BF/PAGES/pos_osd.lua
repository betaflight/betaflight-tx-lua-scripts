local template = assert(loadScript(radio.template))()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
local yMinLim = radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local inc = { x = function(val) x = x + val return x end, y = function(val) y = y + val return y end }
local labels = {}
local fields = {}

local items = {
    {["address"] = 0,  ["firstVal"] = 11,  ["secondVal"] = 12,  ["nameCli"] = "rssi_pos"},
    {["address"] = 1,  ["firstVal"] = 13,  ["secondVal"] = 14,  ["nameCli"] = "vbat_pos"},
    {["address"] = 2,  ["firstVal"] = 15,  ["secondVal"] = 16,  ["nameCli"] = "crosshairs_pos"},
    {["address"] = 3,  ["firstVal"] = 17,  ["secondVal"] = 18,  ["nameCli"] = "ah_pos"},
    {["address"] = 4,  ["firstVal"] = 19,  ["secondVal"] = 20,  ["nameCli"] = "ah_sbar_pos"},
    {["address"] = 5,  ["firstVal"] = 21,  ["secondVal"] = 22,  ["nameCli"] = "tim_1_pos"},
    {["address"] = 6,  ["firstVal"] = 23,  ["secondVal"] = 24,  ["nameCli"] = "tim_2_pos"},
    {["address"] = 7,  ["firstVal"] = 25,  ["secondVal"] = 26,  ["nameCli"] = "flymode_pos"},
    {["address"] = 8,  ["firstVal"] = 27,  ["secondVal"] = 28,  ["nameCli"] = "craft_name_pos"},
    {["address"] = 9,  ["firstVal"] = 29,  ["secondVal"] = 30,  ["nameCli"] = "throttle_pos"},
    {["address"] = 10, ["firstVal"] = 31,  ["secondVal"] = 32,  ["nameCli"] = "vtx_channel_pos"},
    {["address"] = 11, ["firstVal"] = 33,  ["secondVal"] = 34,  ["nameCli"] = "current_pos"},
    {["address"] = 12, ["firstVal"] = 35,  ["secondVal"] = 36,  ["nameCli"] = "mah_drawn_pos"},
    {["address"] = 13, ["firstVal"] = 37,  ["secondVal"] = 38,  ["nameCli"] = "gps_speed_pos"},
    {["address"] = 14, ["firstVal"] = 39,  ["secondVal"] = 40,  ["nameCli"] = "gps_sats_pos"},
    {["address"] = 15, ["firstVal"] = 41,  ["secondVal"] = 42,  ["nameCli"] = "altitude_pos"},
    {["address"] = 16, ["firstVal"] = 43,  ["secondVal"] = 44,  ["nameCli"] = "pid_roll_pos"},
    {["address"] = 17, ["firstVal"] = 45,  ["secondVal"] = 46,  ["nameCli"] = "pid_pitch_pos"},
    {["address"] = 18, ["firstVal"] = 47,  ["secondVal"] = 48,  ["nameCli"] = "pid_yaw_pos"},
    {["address"] = 19, ["firstVal"] = 49,  ["secondVal"] = 50,  ["nameCli"] = "power_pos"},
    {["address"] = 20, ["firstVal"] = 51,  ["secondVal"] = 52,  ["nameCli"] = "pidrate_profile_pos"},
    {["address"] = 21, ["firstVal"] = 53,  ["secondVal"] = 54,  ["nameCli"] = "warnings_pos"},
    {["address"] = 22, ["firstVal"] = 55,  ["secondVal"] = 56,  ["nameCli"] = "avg_cell_voltage_pos"},
    {["address"] = 23, ["firstVal"] = 57,  ["secondVal"] = 58,  ["nameCli"] = "gps_lon_pos"},
    {["address"] = 24, ["firstVal"] = 59,  ["secondVal"] = 60,  ["nameCli"] = "gps_lat_pos"},
    {["address"] = 25, ["firstVal"] = 61,  ["secondVal"] = 62,  ["nameCli"] = "debug_pos"},
    {["address"] = 26, ["firstVal"] = 63,  ["secondVal"] = 64,  ["nameCli"] = "pit_ang_pos"},
    {["address"] = 27, ["firstVal"] = 65,  ["secondVal"] = 66,  ["nameCli"] = "rol_ang_pos"},
    {["address"] = 28, ["firstVal"] = 67,  ["secondVal"] = 68,  ["nameCli"] = "battery_usage_pos"},
    {["address"] = 29, ["firstVal"] = 69,  ["secondVal"] = 70,  ["nameCli"] = "disarmed_pos"},
    {["address"] = 30, ["firstVal"] = 71,  ["secondVal"] = 72,  ["nameCli"] = "home_dir_pos"},
    {["address"] = 31, ["firstVal"] = 73,  ["secondVal"] = 74,  ["nameCli"] = "home_dist_pos"},
    {["address"] = 32, ["firstVal"] = 75,  ["secondVal"] = 76,  ["nameCli"] = "nheading_pos"},
    {["address"] = 33, ["firstVal"] = 77,  ["secondVal"] = 78,  ["nameCli"] = "nvario_pos"},
    {["address"] = 34, ["firstVal"] = 79,  ["secondVal"] = 80,  ["nameCli"] = "compass_bar_pos"},
    {["address"] = 35, ["firstVal"] = 81,  ["secondVal"] = 82,  ["nameCli"] = "esc_tmp_pos"},
    {["address"] = 36, ["firstVal"] = 83,  ["secondVal"] = 84,  ["nameCli"] = "esc_rpm_pos"},
    {["address"] = 37, ["firstVal"] = 85,  ["secondVal"] = 86,  ["nameCli"] = "remaining_time_estimate_pos"},
    {["address"] = 38, ["firstVal"] = 87,  ["secondVal"] = 88,  ["nameCli"] = "rtc_date_time_pos"},
    {["address"] = 39, ["firstVal"] = 89,  ["secondVal"] = 90,  ["nameCli"] = "adjustment_range_pos"},
    {["address"] = 40, ["firstVal"] = 91,  ["secondVal"] = 92,  ["nameCli"] = "core_temp_pos"},
    {["address"] = 41, ["firstVal"] = 93,  ["secondVal"] = 94,  ["nameCli"] = "anti_gravity_pos"},
    {["address"] = 42, ["firstVal"] = 95,  ["secondVal"] = 96,  ["nameCli"] = "g_force_pos"},
    {["address"] = 43, ["firstVal"] = 97,  ["secondVal"] = 98,  ["nameCli"] = "motor_diag_pos"},
    {["address"] = 44, ["firstVal"] = 99,  ["secondVal"] = 100, ["nameCli"] = "log_status_pos"},
    {["address"] = 45, ["firstVal"] = 101, ["secondVal"] = 102, ["nameCli"] = "flip_arrow_pos"},
    {["address"] = 46, ["firstVal"] = 103, ["secondVal"] = 104, ["nameCli"] = "link_quality_pos"},
    {["address"] = 47, ["firstVal"] = 105, ["secondVal"] = 106, ["nameCli"] = "flight_dist_pos"},
    {["address"] = 48, ["firstVal"] = 107, ["secondVal"] = 108, ["nameCli"] = "stick_overlay_left_pos"},
    {["address"] = 49, ["firstVal"] = 109, ["secondVal"] = 110, ["nameCli"] = "stick_overlay_right_pos"},
    {["address"] = 50, ["firstVal"] = 111, ["secondVal"] = 112, ["nameCli"] = "display_name_pos"},
    {["address"] = 51, ["firstVal"] = 113, ["secondVal"] = 114, ["nameCli"] = "esc_rpm_freq_pos"},
    {["address"] = 52, ["firstVal"] = 115, ["secondVal"] = 116, ["nameCli"] = "rate_profile_name_pos"},
    {["address"] = 53, ["firstVal"] = 117, ["secondVal"] = 118, ["nameCli"] = "pid_profile_name_pos"},
    {["address"] = 54, ["firstVal"] = 119, ["secondVal"] = 120, ["nameCli"] = "profile_name_pos"},
    {["address"] = 55, ["firstVal"] = 121, ["secondVal"] = 122, ["nameCli"] = "rssi_dbm_pos"},
    {["address"] = 56, ["firstVal"] = 123, ["secondVal"] = 124, ["nameCli"] = "rcchannels_pos"},
    {["address"] = 57, ["firstVal"] = 125, ["secondVal"] = 126, ["nameCli"] = "camera_frame_pos"},
    {["address"] = 58, ["firstVal"] = 127, ["secondVal"] = 128, ["nameCli"] = "efficiency_pos"},
    {["address"] = 59, ["firstVal"] = 129, ["secondVal"] = 130, ["nameCli"] = "total_flights_pos"},
    {["address"] = 60, ["firstVal"] = 131, ["secondVal"] = 132, ["nameCli"] = "up_down_reference_pos"},
    {["address"] = 61, ["firstVal"] = 133, ["secondVal"] = 134, ["nameCli"] = "link_tx_power_pos"},
    {["address"] = 62, ["firstVal"] = 135, ["secondVal"] = 136, ["nameCli"] = "wh_drawn_pos"},
    {["address"] = 63, ["firstVal"] = 137, ["secondVal"] = 138, ["nameCli"] = "aux_pos"},
    {["address"] = 64, ["firstVal"] = 139, ["secondVal"] = 140, ["nameCli"] = "ready_mode_pos"},
    {["address"] = 65, ["firstVal"] = 141, ["secondVal"] = 142, ["nameCli"] = "rsnr_pos"},
    {["address"] = 66, ["firstVal"] = 143, ["secondVal"] = 144, ["nameCli"] = "sys_goggle_voltage_pos"},
    {["address"] = 67, ["firstVal"] = 145, ["secondVal"] = 146, ["nameCli"] = "sys_vtx_voltage_pos"},
    {["address"] = 68, ["firstVal"] = 147, ["secondVal"] = 148, ["nameCli"] = "sys_bitrate_pos"},
    {["address"] = 69, ["firstVal"] = 149, ["secondVal"] = 150, ["nameCli"] = "sys_delay_pos"},
    {["address"] = 70, ["firstVal"] = 151, ["secondVal"] = 152, ["nameCli"] = "sys_distance_pos"},
    {["address"] = 71, ["firstVal"] = 153, ["secondVal"] = 154, ["nameCli"] = "sys_lq_pos"},
    {["address"] = 72, ["firstVal"] = 155, ["secondVal"] = 156, ["nameCli"] = "sys_goggle_dvr_pos"},
    {["address"] = 73, ["firstVal"] = 157, ["secondVal"] = 158, ["nameCli"] = "sys_vtx_dvr_pos"},
    {["address"] = 74, ["firstVal"] = 159, ["secondVal"] = 160, ["nameCli"] = "sys_warnings_pos"},
    {["address"] = 75, ["firstVal"] = 161, ["secondVal"] = 162, ["nameCli"] = "sys_vtx_temp_pos"},
    {["address"] = 76, ["firstVal"] = 163, ["secondVal"] = 164, ["nameCli"] = "sys_fan_speed_pos"},
}

address = address or 0
local firstVal = items[address + 1]["firstVal"]
local secondVal = items[address + 1]["secondVal"]
local nameCli = items[address + 1]["nameCli"]

x = margin
y = yMinLim - tableSpacing.header

fields[#fields + 1] = {              x = x,                        y = inc.y(tableSpacing.header), min = 0, max = (#items - 1), vals = { 1 }, upd = function(self) self.updateItems(self) end }
labels[#labels + 1] = { t = nameCli, x = x + tableSpacing.col * 1, y = y }

labels[#labels + 1] = { t = "POS",   x = x,                        y = inc.y(tableSpacing.header) }
labels[#labels + 1] = { t = "OP1",   x = x + tableSpacing.col,     y = y }
labels[#labels + 1] = { t = "OP2",   x = x + tableSpacing.col * 2, y = y }
labels[#labels + 1] = { t = "OP3",   x = x + tableSpacing.col * 3, y = y }

fields[#fields + 1] = {              x = x,                        y = inc.y(tableSpacing.row), min = 0, max = 2047, vals = { 2, 3 } }
fields[#fields + 1] = {              x = x + tableSpacing.col,     y = y, min = 0, max = 1, vals = { 1, 2 }, table = { [0] = "OFF", "ON" } }
fields[#fields + 1] = {              x = x + tableSpacing.col * 2, y = y, min = 0, max = 1, vals = { 1, 2 }, table = { [0] = "OFF", "ON" } }
fields[#fields + 1] = {              x = x + tableSpacing.col * 3, y = y, min = 0, max = 1, vals = { 1, 2 }, table = { [0] = "OFF", "ON" } }

return {
    read        = 84, -- MSP_OSD_CONFIG
    write       = 85, -- MSP_SET_OSD_CONFIG
    title       = "OSD Elements",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 3,
    labels      = labels,
    fields      = fields,
    postLoad = function(self)
        self.fields[1].value = address
        self.fields[2].value, self.fields[3].value, self.fields[4].value, self.fields[5].value = self.splitVal(self, self.values[firstVal], self.values[secondVal])
    end,
    preSave = function(self)
        self.values = {}
        self.values[1] = self.fields[1].value
        local combineValue = self.checkProfile(self, self.fields[2].value, self.fields[3].value, self.fields[4].value, self.fields[5].value)
        self.values[2] = bit32.band(combineValue, 0xFF)
        self.values[3] = bit32.rshift(combineValue, 8)
        return self.values
    end,
    checkProfile = function(self, value, profileFirst, profileSecond, profileThird)
        local profiles = profileFirst + bit32.lshift(profileSecond, 1) + bit32.lshift(profileThird, 2)
        local output = bit32.replace(value, profiles, 11, 3)
        return output
    end,
    splitVal = function(self, inputFirstVal, inputSecondVal)
        local inputVal = inputFirstVal + bit32.lshift(inputSecondVal, 8)
        local profiles = bit32.extract(inputVal, 11, 3)
        local fieldPos = bit32.extract(inputVal, 0, 11)
        local fieldFirstProfile = bit32.band(bit32.rshift(profiles, 0), 1)
        local FieldSecondProfile = bit32.band(bit32.rshift(profiles, 1), 1)
        local FieldThirdProfile = bit32.band(bit32.rshift(profiles, 2), 1)
        return fieldPos, fieldFirstProfile, FieldSecondProfile, FieldThirdProfile
    end,
    updateItems = function(self)
        if self.fields[1].value ~= items[address + 1]["address"] then
            address = self.fields[1].value
            firstVal = items[address + 1]["firstVal"]
            secondVal = items[address + 1]["secondVal"]
            address = items[address + 1]["address"]
            nameCli = items[address + 1]["nameCli"]
            self.labels[1].t = nameCli
            self.fields[2].value, self.fields[3].value, self.fields[4].value, self.fields[5].value = self.splitVal(self, self.values[firstVal], self.values[secondVal])
        end
    end
}
