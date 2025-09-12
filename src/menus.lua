local http_request = require "http.request"

local config = require("config")
local menu = require("menu")
local save = require("save")
local colors = require("colors")

local menus = {}

local title = [[ _                   _
| |_   _  __ _ _ __ (_)
| | | | |/ _` | '_ \| |
| | |_| | (_| | |_) | |
|_|\__,_|\__,_| .__/|_|
              |_|

]]

local verbs_colors = {
    ["GET"] = colors.CYAN,
}

menus.HOME = function()
    save.mkdir_p(config.save_path)

    local ok, _ = save.load(config.save_path .. "/save.json")

    if not ok then
        save.save(config.save_path .. "/save.json", { ["snippets"] = {} })
    end

    menu:new(menu.modes["CHOICES"], title .. "A cURL app to view HTTP snippets",
        { "📌 View snippets", "🎯 Direct connection", "🔙 Quit" },
        {
            function()
                menus.SNIPPETS()
            end,
            function()

            end,
            function()
                os.exit()
            end
        }
    ):execute()
end

menus.SNIPPETS = function()
    menu:new(menu.modes["CHOICES"], title .. "Choose a snippet",
        (function()
            local ok, data = save.load(config.save_path .. "/save.json")

            if not ok then
                error(colors.colorize(data, colors.RED))
            end

            local snippets = {
                "🔙 Back to home",
                "➕ Create a snippet"
            }

            for _, snippet in ipairs(data.snippets) do
                table.insert(snippets,
                    colors.colorize(snippet.verb, verbs_colors[snippet.verb] or colors.ITALIC, colors.BOLD) ..
                    " " .. snippet.name)
            end

            return snippets
        end)(),
        (function()
            local ok, data = save.load(config.save_path .. "/save.json")

            if not ok then
                error(colors.colorize(data))
            end

            local funcs = {}

            for i, snippet in ipairs(data.snippets) do
                funcs[i] = function()
                    menus.SNIPPET_VIEW(snippet)
                end
            end

            table.insert(funcs, 1, function()
                menus.HOME()
            end)
            table.insert(funcs, 2, function()
                menus.SNIPPET_CREATE()
            end)

            return funcs
        end)()
    ):execute()
end

menus.SNIPPET_CREATE = function()
    menu:new(menu.modes["TEXTINPUT"], title .. "Create a snippet",
        function(input)
            local ok, data = save.load(config.save_path .. "/save.json")

            if not ok then
                error(data)
            end

            local snippet = { name = input, url = input, verb = "GET", payload = "" }

            table.insert(data.snippets, snippet)

            save.save(config.save_path .. "/save.json", data)
            menus.SNIPPETS()
        end
    ):execute()
end

menus.SNIPPET_VIEW = function(snippet)
    menu:new(menu.modes["CHOICES"],
        title .. snippet.name ..
        "\nURL: " .. colors.colorize(snippet.url, colors.UNDERLINE) ..
        "\nMethod: " .. colors.colorize(snippet.verb, verbs_colors[snippet.verb] or colors.ITALIC, colors.BOLD),
        { "📤 Execute", "✏️  Rename", "🔗 Change URL", "⚡ Change method", "📦 Change Payload", "🔙 Back to snippets" },
        {
            function()
                -- REQUEST
                local headers, stream = assert(http_request.new_from_uri(snippet.url):go())
                local body = assert(stream:get_body_as_string())

                -- RESPONSE
                local res = {
                    headers = headers,
                    body = #body > 0 and body or colors.colorize("No body", colors.RED),
                    status = headers:get(":status") or colors.colorize("No status", colors.RED)
                }

                menus.SNIPPET_RESPONSE(snippet, res)
            end
        }
    ):execute()
end

menus.SNIPPET_RESPONSE = function(snippet, res)
    menu:new(menu.modes["INFORMATIONS"],
        title .. snippet.name ..
        "\nURL: " .. colors.colorize(snippet.url, colors.UNDERLINE) ..
        "\nMethod: " .. colors.colorize(snippet.verb, verbs_colors[snippet.verb] or colors.ITALIC, colors.BOLD),
        "\nPayload: " .. res.body ..
        "\nStatus: " .. res.status
    ):execute()
    menus.SNIPPET_VIEW(snippet)
end

return menus
