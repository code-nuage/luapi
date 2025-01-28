local Menu = require("libs.menu")
local Data = require("data")

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

            table.insert(datas.snippets, 1, "🔙 Back to home")
            table.insert(datas.snippets, 2, "➕ Create a snippet")

            return datas.snippets
        end)(),
        (function()
            local datas = Data.read()
            local funcs = {}

            for i, snippet in ipairs(datas.snippets) do
                funcs[i] = function()
                    SELECTED_SNIPPET = snippet
                    Menus.VIEW_SNIPPET()
                end
            end

            table.insert(funcs, 1, function()
                Menus.HOME()
            end)
            table.insert(funcs, 2, function()
                Menus.CREATE_SNIPPET()
            end)

            return funcs
        end)()
    )
    menu:execute()
end

Menus.CREATE_SNIPPET = function()
    local menu = Menu:new("textinput", title .. "Create a snippet",
        function(input)
            Data.append(input)
            Menus.SNIPPETS()
        end
    )
    menu:execute()
end

Menus.VIEW_SNIPPET = function()
    local menu = Menu:new("choices", title .. "Snippet",
        {
            "🔙 Back to snippets",
            "🚀 Execute",
            "🚮 Delete"
        },
        {
            function()
                Menus.SNIPPETS()
            end,
            function()

            end,
            function()
                local datas = Data.read()

                for i = #datas.snippets, 1, -1 do
                    if datas.snippets[i] == SELECTED_SNIPPET then
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

return Menus