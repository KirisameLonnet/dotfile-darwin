-- SbarLua Configuration - FelixKratz Style
-- ~/.config/sketchybar/init.lua

sbar = require("sketchybar")

-- ============================================================================
-- BAR CONFIGURATION
-- ============================================================================


-- Catppuccin Mocha Colors
local colors = {
    bg = 0xff1e1e2e,        -- Base background
    fg = 0xffcdd6f4,        -- Primary text
    surface0 = 0xff313244,  -- Inactive elements
    surface1 = 0xff45475a,  -- Secondary elements
    blue = 0xff89b4fa,      -- Accent blue
    green = 0xffa6e3a1,     -- Success green
    yellow = 0xfff9e2af,    -- Warning yellow
    red = 0xfff38ba8,       -- Error red
    mauve = 0xffcba6f7,     -- Mauve accent
    pink = 0xfff5c2e7,      -- Pink accent
    teal = 0xff94e2d5,      -- Teal accent
    subtext = 0xffa6adc8,   -- Secondary text
}

-- Bar appearance - positioned to replace macOS menu bar
sbar.bar({
    height = 32,                -- Standard menu bar height
    color = colors.bg,
    border_color = colors.surface1,
    border_width = 1,
    corner_radius = 0,          -- Sharp corners for system integration
    padding_left = 8,           -- Reduced padding for system bar feel
    padding_right = 8,
    margin = 0,                 -- No margin - flush with screen edge
    y_offset = 0,               -- Positioned at absolute top
    shadow = true,
    position = "top",
    sticky = true,
    topmost = "window",         -- Stay on top of windows but below system UI
    blur_radius = 30,           -- Add blur for modern look
})

-- ============================================================================
-- DEFAULT ITEM SETTINGS
-- ============================================================================

sbar.default({
    updates = "when_shown",
    icon = {
        font = {
            family = "JetBrainsMono Nerd Font",
            style = "Bold",
            size = 17.0
        },
        color = colors.fg,
        padding_left = 10,
        padding_right = 4,
        background = {
            height = 24,
            corner_radius = 6,
        }
    },
    label = {
        font = {
            family = "JetBrainsMono Nerd Font", 
            style = "Bold",
            size = 14.0
        },
        color = colors.fg,
        padding_left = 4,
        padding_right = 10,
        background = {
            height = 24,
            corner_radius = 6,
        }
    },
    background = {
        height = 28,
        corner_radius = 8,
        border_width = 1,
        border_color = colors.surface1,
        color = colors.surface0,
    },
    popup = {
        background = {
            border_width = 2,
            corner_radius = 8,
            border_color = colors.blue,
            color = colors.bg,
        }
    }
})

-- ============================================================================
-- ITEM DEFINITIONS
-- ============================================================================

-- Left side items
sbar.add("item", "logo", {
    position = "left",
    icon = {
        string = "󰀵",
        color = colors.blue,
        font = {
            size = 20.0,
            style = "Bold"
        }
    },
    label = { drawing = false },
    background = {
        color = colors.surface1,
        border_color = colors.blue,
        border_width = 1,
    },
    padding_left = 10,
    padding_right = 10,
    click_script = "open -a 'Raycast'"
})

-- Spaces (similar to FelixKratz's layout)
for i = 1, 10 do
    sbar.add("space", "space." .. i, {
        space = i,
        icon = {
            string = i,
            color = colors.subtext,
            highlight_color = colors.blue,
        },
        label = { drawing = false },
        background = {
            color = colors.surface0,
            border_color = colors.surface1,
            border_width = 1,
        },
        script = "$CONFIG_DIR/plugins/space.sh " .. i,
    })
end

-- Front app indicator
sbar.add("item", "front_app", {
    position = "left",
    icon = { drawing = false },
    label = {
        color = colors.fg,
        font = {
            style = "Bold",
            size = 15.0
        }
    },
    background = {
        color = colors.surface0,
        border_color = colors.green,
        border_width = 1,
    },
    script = "$CONFIG_DIR/plugins/front_app.sh",
    click_script = "open -a 'Mission Control'"
})

-- Center items
sbar.add("item", "media", {
    position = "center",
    icon = {
        string = "󰝚",
        color = colors.teal,
    },
    label = {
        max_chars = 30,
        color = colors.fg,
    },
    background = {
        color = colors.surface0,
        border_color = colors.teal,
        border_width = 1,
    },
    script = "$CONFIG_DIR/plugins/media.sh",
    updates = "on",
})

-- Right side items
sbar.add("item", "wifi", {
    position = "right",
    icon = {
        string = "󰖩",
        color = colors.blue,
    },
    label = { drawing = false },
    background = {
        color = colors.surface0,
        border_color = colors.blue,
        border_width = 1,
    },
    script = "$CONFIG_DIR/plugins/wifi.sh",
    click_script = "open 'x-apple.systempreferences:com.apple.Network-Settings.extension'"
})

sbar.add("item", "volume", {
    position = "right",
    icon = {
        string = "󰕾",
        color = colors.yellow,
    },
    label = {
        color = colors.fg,
    },
    background = {
        color = colors.surface0,
        border_color = colors.yellow,
        border_width = 1,
    },
    script = "$CONFIG_DIR/plugins/volume.sh",
    click_script = "$CONFIG_DIR/plugins/volume_click.sh"
})

sbar.add("item", "battery", {
    position = "right",
    icon = {
        string = "󰁹",
        color = colors.green,
    },
    label = {
        color = colors.fg,
    },
    background = {
        color = colors.surface0,
        border_color = colors.green,
        border_width = 1,
    },
    script = "$CONFIG_DIR/plugins/battery.sh",
    updates = "routine",
})

sbar.add("item", "clock", {
    position = "right",
    icon = {
        string = "󰅐",
        color = colors.mauve,
    },
    label = {
        color = colors.fg,
        font = {
            style = "Bold",
            size = 14.0
        }
    },
    background = {
        color = colors.surface0,
        border_color = colors.mauve,
        border_width = 1,
    },
    script = "$CONFIG_DIR/plugins/clock.sh",
    updates = "on",
    click_script = "open -a 'Calendar'"
})

-- ============================================================================
-- EVENT HANDLING
-- ============================================================================

-- Subscribe to yabai events
sbar.subscribe("space_change", function(env)
    -- Update space indicators
    for i = 1, 10 do
        local selected = (env.SELECTED == "true" and env.SID == tostring(i))
        sbar.set("space." .. i, {
            background = { 
                color = selected and colors.blue or colors.surface0,
                border_color = selected and colors.blue or colors.surface1,
            },
            icon = { 
                color = selected and colors.bg or colors.subtext 
            }
        })
    end
end)

sbar.subscribe("window_focus", function(env)
    -- Update front app when window focus changes
    sbar.exec("$CONFIG_DIR/plugins/front_app.sh")
end)

-- ============================================================================
-- FINALIZATION
-- ============================================================================

-- Run the bar
sbar.hotload(true)
sbar.run()
