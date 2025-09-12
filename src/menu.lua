local colors = require("colors")

local function clear()
    io.write("\27[2J\27[H")
end

local Menu = {}
Menu.__index = Menu

Menu.modes = {
    ["CHOICES"] = 1,
    ["TEXTINPUT"] = 2,
    ["INFORMATIONS"] = 3
}

function Menu:new(mode, title, descriptors, callbacks)
    local i = setmetatable({}, Menu)

    i:set_mode(mode or Menu.modes["INFORMATIONS"])
    i:set_title(title or "This menu has'nt any title")
    if descriptors then i.descriptors = descriptors end
    if callbacks then i.callbacks = callbacks end

    return i
end

function Menu:set_mode(mode)
    assert(type(mode) == "number", colors.colorize("<mode>: must be a number", colors.RED))
    self.mode = mode
    return self
end

function Menu:set_title(title)
    assert(type(title) == "string", colors.colorize("<title>: must be a string", colors.RED))
    self.title = title
    return self
end

function Menu:execute_choices()
    for index, text in ipairs(self.descriptors) do
        io.write("[" .. index .. "] " .. text .. "\n")
    end

    local input

    repeat
        io.write("\n > ")
        input = io.read()
        if tonumber(input) then input = tonumber(input) end
    until type(input) == "number" and input >= 1 and input <= #self.callbacks

    self.callbacks[input]()
end

function Menu:execute_textinput()
    io.write("\n > ")
    local input = io.read()
    self.descriptors(input)
end

function Menu:execute_informations()
    io.write(self.descriptors)
    io.write("\n > ")
    local _ = io.read()
end

function Menu:execute()
    clear()
    io.write(self.title .. "\n\n")

    if self.mode == 1 then
        self:execute_choices()
    elseif self.mode == 2 then
        self:execute_textinput()
    elseif self.mode == 3 then
        self:execute_informations()
    end
end

function Menu:update(title, descriptors, callbacks)
    self.title = title
    if descriptors then self.descriptors = descriptors end
    if callbacks then self.callbacks = callbacks end
end

return Menu
