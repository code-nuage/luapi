require("io")

local function clear()
	local path_sep = package.config:sub(1, 1)
	if path_sep == "\\" then
		os.execute("cls")
	else
		os.execute("clear")
	end
end

local Menu = {}
Menu.__index = Menu

function Menu:new(type, title, arg1, arg2)
	local instance = setmetatable({}, Menu)

	instance.type = type
	instance.title = title
	if arg1 then instance.arg1 = arg1 end
	if arg2 then instance.arg2 = arg2 end

	return instance
end

local function Execute_Choices(instance)
	for i, text in ipairs(instance.arg1) do
		io.write("[" .. i .. "] " .. text .. "\n")
	end

	local input

	repeat
		io.write("\n > ")
		input = io.read()
		if tonumber(input) then input = tonumber(input) end
	until type(input) == "number" and input >= 1 and input <= #instance.arg2

	instance.arg2[input]()
end

local function Execute_TextInput(instance)
	io.write("\n > ")
	local input = io.read()
	instance.arg1(input)
end

function Menu:execute()
	clear()
	io.write(self.title .. "\n\n")

	if self.type == "choices" then Execute_Choices(self)
	elseif self.type == "textinput" then Execute_TextInput(self) end
end

function Menu:update(title, arg1, arg2)
	self.title = title
	if arg1 then self.arg1 = arg1 end
	if arg2 then self.arg2 = arg2 end
end

return Menu