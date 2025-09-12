local function create_color(i)
    return "\27[" .. i .. "m"
end

local M = {
    RESET = create_color(0),

    BOLD = create_color(1),
    ITALIC = create_color(3),
    UNDERLINE = create_color(4),
    REVERSE = create_color(7),
    STRIKETHROUGH = create_color(9),

    BLACK = create_color(30),
    RED = create_color(31),
    GREEN = create_color(32),
    YELLOW = create_color(33),
    BLUE = create_color(34),
    MAGENTA = create_color(35),
    CYAN = create_color(36),
    WHITE = create_color(37),

    BLACK_BG = create_color(40),
    RED_BG = create_color(41),
    GREEN_BG = create_color(42),
    YELLOW_BG = create_color(43),
    BLUE_BG = create_color(44),
    MAGENTA_BG = create_color(45),
    CYAN_BG = create_color(46),
    WHITE_BG = create_color(47),

    MODES = {
        foreground = 3,
        background = 4
    }
}


M.rgb = function(r, g, b, mode)
    local mode_n = mode or 3
    return "\27[" .. mode_n .. "8;2;" .. r .. ";" .. g .. ";" .. b .. "m"
end

M.colorize = function(text, ...)
    local colors = { ... }
    if #colors == 0 then
        return text
    end
    local result = text
    for _, c in ipairs(colors) do
        result = c .. result
    end
    return result .. M.RESET
end

return M
