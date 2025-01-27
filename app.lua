local io = require("io")
local json = require("json")
local Menu = require("menu")

local title = [[
  _                   _ 
 | |                 (_)
 | |_   _  __ _ _ __  _ 
 | | | | |/ _` | '_ \| |
 | | |_| | (_| | |_) | |
 |_|\__,_|\__,_| .__/|_|
               | |      
               |_|      
]]

local App = {}

local function snippets_loader()
	local file = io.open("data.json", "r")
	local content
	local data

	if file then
		content = file:read("*a")

		if content and content ~= "" then
			data = json.decode(content)
		end
	end

	return data.snippets
end

local function snippets_execute()
	local file = io.open("data.json", "r")
	local content
	local data
	local actions = {}

	if file then
		content = file:read("*a")

		if content and content ~= "" then
			data = json.decode(content)
		end
	end

	for i, snippet in ipairs(data.snippets) do
		actions[i] = function()
			local handle = io.popen("curl --location " .. snippet)
			print("curl --location " .. snippet)
			if handle then
				local result = handle:read("*a")
				handle:close()

				io.write("\nRequest result: " .. result)
			end
		end
	end

	return actions
end

function App:load()
	App:init()

	SAVE_SNIPPET = Menu:new("textinput", title .. "Save a snippet to the local data.", function(input)
		io.write(input)
		local file = io.open("data.json", "a+")
		local data
		local content
		if file then
			content = file:read("*a")

			if content and content ~= "" then
				data = json.decode(content)
				data.snippets[#data.snippets + 1] = input
			end
		else
			error("Can't open the file.")
		end

		file:close()

		file = io.open("data.json", "w+")

		if file then
			file:write(json.encode(data))
		end

		HOME:execute()
	end)

	LOAD_SNIPPET = Menu:new("choices", title .. "Load a snippet for the local data.", snippets_loader(), snippets_execute())

	HOME = Menu:new("choices", title .. "luapi - A cURL based API reader", {"Save a snippet", "Load a snippet"}, {
		function()
			SAVE_SNIPPET:execute()
		end,
		function()
			LOAD_SNIPPET:update(LOAD_SNIPPET.title, snippets_loader(), snippets_execute())
			LOAD_SNIPPET:execute()

			io.write("\nPress enter > ")
			local input = io.read()

			HOME:execute()
		end
	})

	App:execute()
end

function App:init()
	-- Init data.json file
	local file = io.open("data.json", "a+")

	if file then
		local content = file:read("*a")

		if content == "" then
			file:write(json.encode({snippets = {}}))
		end

		file:close()
	end
end

function App:execute()
	HOME:execute()
end

App:load()