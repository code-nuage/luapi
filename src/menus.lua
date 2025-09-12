local http = require("http")

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
    ["GET"] = colors.CYAN_BG,
    ["POST"] = colors.BLUE_BG,
    ["PUT"] = colors.GREEN_BG,
    ["PATCH"] = colors.GREEN_BG,
    ["DELETE"] = colors.RED_BG,
    ["CONNECT"] = colors.MAGENTA_BG,
    ["OPTIONS"] = colors.MAGENTA_BG,
    ["TRACE"] = colors.MAGENTA_BG,
}

local function get_snippet_by_id(id)
    local ok, data = save.load(config.save_path .. "/save.json")

    if not ok then
        error(data)
    end

    for _, s in ipairs(data.snippets) do
        if s.id == id then
            return true, s
        end
    end
    return false, "Can't find snippet with ID " .. id
end

menus.HOME = function()
    save.mkdir_p(config.save_path)

    local ok, _ = save.load(config.save_path .. "/save.json")

    if not ok then
        save.save(config.save_path .. "/save.json", { ["snippets"] = {} })
    end

    menu:new(menu.modes["CHOICES"], title .. "A cURL app to view HTTP snippets",
        {
            colors.colorize("View snippets", colors.BLUE),
            colors.colorize("Direct connection", colors.CYAN),
            colors.colorize("Quit", colors.RED)
        },
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
                colors.colorize("Back to home", colors.RED),
                colors.colorize("Create a snippet", colors.CYAN)
            }

            for _, snippet in ipairs(data.snippets) do
                table.insert(snippets,
                    colors.colorize(" " .. snippet.verb .. " ", verbs_colors[snippet.verb] or colors.ITALIC, colors.BOLD) ..
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
                    menus.SNIPPET_VIEW(snippet.id)
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

            local last_id = 0

            for _, s in ipairs(data.snippets) do
                last_id = s.id > last_id and s.id or last_id
            end

            local new_id = last_id + 1

            local snippet = { id = new_id, name = input, url = input, verb = "GET", payload = "" }

            table.insert(data.snippets, snippet)

            save.save(config.save_path .. "/save.json", data)
            menus.SNIPPETS()
        end
    ):execute()
end

menus.SNIPPET_VIEW = function(id)
    local ok, snippet = get_snippet_by_id(id)

    if not ok then
        error(snippet)
    end

    menu:new(menu.modes["CHOICES"],
        title ..
        "\nSnippet: " .. snippet.name ..
        "\nURL: " .. colors.colorize(snippet.url, colors.UNDERLINE) ..
        "\nMethod: " .. colors.colorize(" " .. snippet.verb .. " ", verbs_colors[snippet.verb] or colors.ITALIC, colors.BOLD),
        {
            colors.colorize("Execute", colors.BLUE),
            colors.colorize("Rename", colors.CYAN),
            colors.colorize("Change URL", colors.GREEN),
            colors.colorize("Change method", colors.YELLOW),
            colors.colorize("Change Payload", colors.RED),
            colors.colorize("Back to snippets", colors.MAGENTA)
        },
        {
            function()
                -- REQUEST
                local body, code, headers, status = http.perform(snippet.url)

                -- RESPONSE
                local res = {
                    headers = headers,
                    body = (not body or #body > 0) and body or colors.colorize("No body", colors.RED),
                    status = status or colors.colorize("No status", colors.RED)
                }

                menus.SNIPPET_RESPONSE(snippet.id, res)
            end,
            function()
                menus.SNIPPET_EDIT(snippet.id, "name")
            end,
            function()
                menus.SNIPPET_EDIT(snippet.id, "url")
            end,
            function()
                menus.SNIPPET_EDIT(snippet.id, "verb")
            end,
            function()
                menus.SNIPPET_EDIT(snippet.id, "payload")
            end,
            function()
                menus.SNIPPETS()
            end
        }
    ):execute()
end

menus.SNIPPET_RESPONSE = function(id, res)
    local ok, snippet = get_snippet_by_id(id)

    if not ok then
        error(snippet)
    end

    menu:new(menu.modes["INFORMATIONS"],
        title ..
        "\nSnippet: " .. snippet.name ..
        "\nURL: " .. colors.colorize(snippet.url, colors.UNDERLINE) ..
        "\nMethod: " .. colors.colorize(" " .. snippet.verb .. " ", verbs_colors[snippet.verb] or colors.ITALIC, colors.BOLD),
        "\nPayload: " .. res.body ..
        "\nStatus: " .. res.status
    ):execute()
    menus.SNIPPET_VIEW(snippet.id)
end

menus.SNIPPET_EDIT = function(id, key)
    local ok, snippet = get_snippet_by_id(id)

    if not ok then
        error(snippet)
    end

    menu:new(menu.modes["TEXTINPUT"],
        title ..
        "\nSnippet: " .. snippet.name ..
        "\nURL: " .. colors.colorize(snippet.url, colors.UNDERLINE) ..
        "\nMethod: " .. colors.colorize(" " .. snippet.verb .. " ", verbs_colors[snippet.verb] or colors.ITALIC, colors.BOLD),
        function(input)
            local ok, data = save.load(config.save_path .. "/save.json")

            if not ok then
                error(data)
            end

            for _, s in ipairs(data.snippets) do
                if s.id == snippet.id then
                    s[key] = input
                end
            end

            save.save(config.save_path .. "/save.json", data)
        end
    ):execute()
    menus.SNIPPET_VIEW(snippet.id)
end

return menus
