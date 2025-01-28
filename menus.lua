local Menu = require("libs.menu")
local Data = require("data")
local json = require("libs.json")

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
                table.insert(snippets, snippet.title)
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
            local data = {title = input, verb = "GET"}
            Data.append(data)
            Menus.SNIPPETS()
        end
    )
    menu:execute()
end

Menus.SNIPPET_VIEW = function()
    local menu = Menu:new("choices", title .. "Snippet: " .. SELECTED_SNIPPET.title .. "\nVerb: " .. SELECTED_SNIPPET.verb,
        {
            "🔙 Back to snippets",
            "🚀 Execute",
            "📝 Edit",
            "🚮 Delete"
        },
        {
            function()
                Menus.SNIPPETS()
            end,
            function()

            end,
            function ()
                Menus.SNIPPET_EDIT()
            end,
            function()
                local datas = Data.read()

                for i = #datas.snippets, 1, -1 do
                    if json.encode(datas.snippets[i]) == json.encode(SELECTED_SNIPPET) then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
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

Menus.SNIPPET_EDIT = function()
    local menu = Menu:new("choices", title .. "Choose a HTTP verb for " .. SELECTED_SNIPPET.title,
        {
            "🔍 GET",
            "✍️ POST",
            "🔄 PUT",
            "🗑️ DELETE",
            "🛠️ PATCH",
            "⚙️ OPTIONS",
            "🧑‍💻 HEAD"
        },
        { -- I obviously have to clean this, but tomorrow
            function()
                local datas = Data.read()

                for i = #datas.snippets, 1, -1 do
                    if json.encode(datas.snippets[i]) == json.encode(SELECTED_SNIPPET) then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
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
                    if json.encode(datas.snippets[i]) == json.encode(SELECTED_SNIPPET) then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
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
                    if json.encode(datas.snippets[i]) == json.encode(SELECTED_SNIPPET) then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
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
                    if json.encode(datas.snippets[i]) == json.encode(SELECTED_SNIPPET) then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
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
                    if json.encode(datas.snippets[i]) == json.encode(SELECTED_SNIPPET) then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
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
                    if json.encode(datas.snippets[i]) == json.encode(SELECTED_SNIPPET) then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
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
                    if json.encode(datas.snippets[i]) == json.encode(SELECTED_SNIPPET) then -- I have to compare the json value of the snippets since they are not located in the same memory block (why ?)
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

return Menus