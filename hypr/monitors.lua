-- Monitor layout, carried over from the previous ml4w setup.
-- The old `monitor = name, resolution@refresh, position, scale` positional form
-- is now one hl.monitor{} call per output, with the fields named.
hl.monitor({ output = "DP-1",     mode = "3840x1600@144.0", position = "1499x1440", scale = 1.0 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60.0",  position = "5339x1819", scale = 1.0 })
hl.monitor({ output = "DP-2",     mode = "2560x1440@59.95", position = "2164x0",    scale = 1.0 })

-- Fallback for anything not listed above (e.g. plugging in a new monitor)
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1.0 })
