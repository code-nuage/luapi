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
Menus.HOME = Menu:new("choices", title .. "A cURL app to view HTTP requests",
    {"📌 View snippets", "🎯 Direct connection", "🔙 Quit"},
    {
        function()
            Menus.SNIPPETS:execute()
        end,
        function()
            
        end,
        function()
            os.exit()
        end
    }
):execute()

Menus.SNIPPETS = Menu:new("choices", title .. "Choose a snippet",
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
                Menus.VIEW_SNIPPET:update(title .. "Snippet: " .. snippet)
                Menus.VIEW_SNIPPET:execute()
            end
        end

        table.insert(funcs, 1, function()
            Menus.HOME:execute()
        end)
        table.insert(funcs, 2, function()
            Menus.CREATE_SNIPPET:execute()
        end)

        return funcs
    end)()
)

Menus.CREATE_SNIPPET = Menu:new("textinput", title .. "Create a snippet",
    function(input)
        Data.append(input)
        Menus.SNIPPETS:update(Menus.SNIPPETS.title,
        (function()
            local datas = Data.read()

            table.insert(datas.snippets, 1, "🔙 Back to home")
            table.insert(datas.snippets, 2, "➕ Create a snippet")

            return datas.snippets
        end)())
        Menus.SNIPPETS:execute() -- To get back to the snippets menu after doing the things
    end
)

Menus.VIEW_SNIPPET = Menu:new("choices", title .. "Snippet",
    {
        "🔙 Back to snippets",
        "🚀 Execute",
        "🚮 Delete"
    },
    {
        function()
            Menus.SNIPPETS:update(Menus.SNIPPETS.title,
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
                            Menus.VIEW_SNIPPET:update(title .. "Snippet: " .. snippet)
                            Menus.VIEW_SNIPPET:execute()
                        end
                    end

                    table.insert(funcs, 1, function()
                        Menus.HOME:execute()
                    end)
                    table.insert(funcs, 2, function()
                        Menus.CREATE_SNIPPET:execute()
                    end)

                    return funcs
                end)()
            )
            Menus.SNIPPETS:execute()
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
            Menus.SNIPPETS:update(Menus.SNIPPETS.title,
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
                            Menus.VIEW_SNIPPET:update(title .. "Snippet: " .. snippet)
                            Menus.VIEW_SNIPPET:execute()
                        end
                    end

                    table.insert(funcs, 1, function()
                        Menus.HOME:execute()
                    end)
                    table.insert(funcs, 2, function()
                        Menus.CREATE_SNIPPET:execute()
                    end)

                    return funcs
                end)()
            )
            Menus.SNIPPETS:execute()
        end
    }
)

return Menus