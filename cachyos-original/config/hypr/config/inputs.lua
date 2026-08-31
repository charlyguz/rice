-- Input configuration

hl.config({
    input = {
        -- sensitivity = -0.25,
        kb_layout = "us,latam",
        kb_options = "grp:alt_shift_toggle",
    	
	-- Mouse externo
        natural_scroll = false,
        accel_profile = "flat",

        -- Touchpad
        touchpad = {
            natural_scroll = true,
            scroll_factor = 0.7,
        },

	},
    -- Uncomment the section below to enable software cursors; this can help with cursor display or behavior issues
    -- cursor = {
    --     no_hardware_cursors = 1,
    -- },
})

hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down",       action = "close" })
hl.gesture({ fingers = 3, direction = "up",         action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "left",       action = "float" })
