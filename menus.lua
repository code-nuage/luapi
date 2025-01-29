local Menu = require("libs.menu")
local json = require("libs.json")

local Data = require("data")
local Requests = require("requests")

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

local Menus = {}

local function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
end

local colors = {
	WHITE = "\27[0;38;5;15m",
	GET = "\27[1;38;5;10m",
	POST = "\27[1;38;5;11m",
	PUT = "\27[1;38;5;14m",
	PATCH = "\27[1;38;5;12m",
	DELETE = "\27[1;38;5;9m",
	HEAD = "\27[1;38;5;2m",
	OPTIONS = "\27[1;38;5;13m",
}

local color_by_code = {
	[200] = "\27[1;38;5;10m",
	[300] = "\27[1;38;5;11m",
	[301] = "\27[1;38;5;11m",
	[302] = "\27[1;38;5;11m",
	[303] = "\27[1;38;5;11m",
	[304] = "\27[1;38;5;11m",
	[305] = "\27[1;38;5;11m",
	[306] = "\27[1;38;5;11m",
	[307] = "\27[1;38;5;11m",
	[308] = "\27[1;38;5;11m",
	[400] = "\27[1;38;5;9m",
	[401] = "\27[1;38;5;9m",
	[402] = "\27[1;38;5;9m",
	[403] = "\27[1;38;5;9m",
	[404] = "\27[1;38;5;9m",
	[500] = "\27[1;38;5;9m"
}

Menus.HOME = function()
    local menu = Menu:new("choices", title .. "A cURL app to view HTTP requests",
        {"📌 View snippets", "🎯 Direct connection", "🔙 Quit"},
        {
            function()
                Menus.SNIPPETS()
            end,
            function()
                
            end,
            function()
                os.exit()
            end
        }
    )
    menu:execute()
end

Menus.SNIPPETS = function ()
    local menu = Menu:new("choices", title .. "Choose a snippet",
        (function()
            local datas = Data.read()
            local snippets = {}

            table.insert(snippets, 1, "🔙 Back to home")
            table.insert(snippets, 2, "➕ Create a snippet")

            for _, snippet in ipairs(datas.snippets) do
                table.insert(snippets, colors[snippet.verb] .. snippet.verb .. " " .. colors.WHITE .. snippet.title)
            end

            return snippets
        end)(),
        (function()
            local datas = Data.read()
            local funcs = {}

            for i, snippet in ipairs(datas.snippets) do
                funcs[i] = function()
                    SELECTED_SNIPPET = snippet
                    Menus.SNIPPET_VIEW()
                end
            end

            table.insert(funcs, 1, function()
                Menus.HOME()
            end)
            table.insert(funcs, 2, function()
                Menus.SNIPPET_CREATE()
            end)

            return funcs
        end)()
    )
    menu:execute()
end

Menus.SNIPPET_CREATE = function()
    local menu = Menu:new("textinput", title .. "Create a snippet",
        function(input)
            local data = {title = input, url = input, verb = "GET", payload = ""}
            Data.append(data)
            Menus.SNIPPETS()
        end
    )
    menu:execute()
end

Menus.SNIPPET_VIEW = function()
    local menu = Menu:new("choices", title .. "Snippet: " .. SELECTED_SNIPPET.title .. "\nURL: " .. SELECTED_SNIPPET.url .. "\nVerb: " .. colors[SELECTED_SNIPPET.verb] .. SELECTED_SNIPPET.verb .. colors.WHITE,
        {
            "🔙 Back to snippets",
            "🚀 Execute",
            "📝 Edit title",
			"📝 Edit URL",
            "📝 Edit verb",
            "📝 Edit payload",
            "🚮 Delete"
        },
        {
            function()
                Menus.SNIPPETS()
            end,
            function()
				Menus.SNIPPET_EXECUTE()
            end,
			function ()
                Menus.SNIPPET_EDIT_TITLE()
			end,
			function ()
                Menus.SNIPPET_EDIT_URL()
			end,
            function ()
                Menus.SNIPPET_EDIT_VERB()
            end,
            function ()
                Menus.SNIPPET_EDIT_PAYLOAD()
            end,
            function()
                local datas = Data.read()

                for i = #datas.snippets, 1, -1 do
                    if datas.snippets[i].title == SELECTED_SNIPPET.title then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
                        table.remove(datas.snippets, i)
                    end
                end

                Data.write(datas)
                Menus.SNIPPETS()
            end
        }
    )
    menu:execute()
end

Menus.SNIPPET_EDIT_TITLE = function ()
	local menu = Menu:new("textinput", title .. "Set title for " .. SELECTED_SNIPPET.title,
		function(input)
			local datas = Data.read()

			for i = #datas.snippets, 1, -1 do
				if datas.snippets[i].title == SELECTED_SNIPPET.title then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
					datas.snippets[i].title = input
					SELECTED_SNIPPET = datas.snippets[i]
					Data.write(datas)
				end
			end

			Menus.SNIPPET_VIEW()
		end

	)
	menu:execute()
end

Menus.SNIPPET_EDIT_URL = function ()
	local menu = Menu:new("textinput", title .. "Edit URL of " .. SELECTED_SNIPPET.title,
		function(input)
			local datas = Data.read()

			for i = #datas.snippets, 1, -1 do
				if datas.snippets[i].title == SELECTED_SNIPPET.title then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
					datas.snippets[i].url = input
					SELECTED_SNIPPET = datas.snippets[i]
					Data.write(datas)
				end
			end

			Menus.SNIPPET_VIEW()
		end
	)

	menu:execute()
end

Menus.SNIPPET_EDIT_PAYLOAD = function ()
	local menu = Menu:new("textinput", title .. "Set the HTTP payload",
		function(input)
			local datas = Data.read()

			for i = #datas.snippets, 1, -1 do
				if datas.snippets[i].title == SELECTED_SNIPPET.title then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
					datas.snippets[i].payload = input
					SELECTED_SNIPPET = datas.snippets[i]
					Data.write(datas)
				end
			end

			Menus.SNIPPET_VIEW()
		end
	)
	
	menu:execute()
end

Menus.SNIPPET_EDIT_VERB = function()
    local menu = Menu:new("choices", title .. "Choose a HTTP verb for " .. SELECTED_SNIPPET.title,
        {
            colors.GET .. "GET" .. colors.WHITE,
            colors.POST .. "POST" .. colors.WHITE,
            colors.PUT .. "PUT" .. colors.WHITE,
            colors.DELETE .. "DELETE" .. colors.WHITE,
            colors.PATCH .. "PATCH" .. colors.WHITE,
            colors.OPTIONS .. "OPTIONS" .. colors.WHITE,
            colors.HEAD .. "HEAD" .. colors.WHITE
        },
        { -- I obviously have to clean this, but tomorrow
            function()
                local datas = Data.read()

                for i = #datas.snippets, 1, -1 do
                    if datas.snippets[i].title == SELECTED_SNIPPET.title then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
                        datas.snippets[i].verb = "GET"
                        SELECTED_SNIPPET = datas.snippets[i]
                        Data.write(datas)
                    end
                end

                Menus.SNIPPET_VIEW()
            end,
            function()
                local datas = Data.read()

                for i = #datas.snippets, 1, -1 do
                    if datas.snippets[i].title == SELECTED_SNIPPET.title then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
                        datas.snippets[i].verb = "POST"
                        SELECTED_SNIPPET = datas.snippets[i]
                        Data.write(datas)
                    end
                end

                Menus.SNIPPET_VIEW()
            end,
            function()
                local datas = Data.read()

                for i = #datas.snippets, 1, -1 do
                    if datas.snippets[i].title == SELECTED_SNIPPET.title then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
                        datas.snippets[i].verb = "PUT"
                        SELECTED_SNIPPET = datas.snippets[i]
                        Data.write(datas)
                    end
                end

                Menus.SNIPPET_VIEW()
            end,
            function()
                local datas = Data.read()

                for i = #datas.snippets, 1, -1 do
                    if datas.snippets[i].title == SELECTED_SNIPPET.title then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
                        datas.snippets[i].verb = "DELETE"
                        SELECTED_SNIPPET = datas.snippets[i]
                        Data.write(datas)
                    end
                end

                Menus.SNIPPET_VIEW()
            end,
            function()
                local datas = Data.read()

                for i = #datas.snippets, 1, -1 do
                    if datas.snippets[i].title == SELECTED_SNIPPET.title then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
                        datas.snippets[i].verb = "PATCH"
                        SELECTED_SNIPPET = datas.snippets[i]
                        Data.write(datas)
                    end
                end

                Menus.SNIPPET_VIEW()
            end,
            function()
                local datas = Data.read()

                for i = #datas.snippets, 1, -1 do
                    if datas.snippets[i].title == SELECTED_SNIPPET.title then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
                        datas.snippets[i].verb = "OPTIONS"
                        SELECTED_SNIPPET = datas.snippets[i]
                        Data.write(datas)
                    end
                end

                Menus.SNIPPET_VIEW()
            end,
            function()
                local datas = Data.read()

                for i = #datas.snippets, 1, -1 do
                    if datas.snippets[i].title == SELECTED_SNIPPET.title then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
                        datas.snippets[i].verb = "HEAD"
                        SELECTED_SNIPPET = datas.snippets[i]
                        Data.write(datas)
                    end
                end

                Menus.SNIPPET_VIEW()
            end,
        }
    )
    menu:execute()
end

Menus.SNIPPET_EXECUTE = function()
	local menu = Menu:new("infos", title .. colors[SELECTED_SNIPPET.verb] .. SELECTED_SNIPPET.verb .. colors.WHITE .. " request at " .. SELECTED_SNIPPET.url,
		(function()
			local code, body
			if SELECTED_SNIPPET.verb == "POST" or SELECTED_SNIPPET.verb == "PUT" then
				code, body = Requests[SELECTED_SNIPPET.verb](SELECTED_SNIPPET.url, SELECTED_SNIPPET.payload)
			else
				code, body = Requests[SELECTED_SNIPPET.verb](SELECTED_SNIPPET.url)
			end

			local color = color_by_code[code]

			return "Code: " .. color .. code .. colors.WHITE .. "\n\nBody: " .. body
		end)()
	)
	menu:execute()
	Menus.SNIPPET_VIEW()
end

return Menus