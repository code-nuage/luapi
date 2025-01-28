local json = require("libs.json")

Data = {}

local function open_error()
    error("Unable to open the file.")
end

function Data.init()
    local file = io.open("data.json", "a+")
    local content
    local data

    if file then
        content = file:read("*a")

        if not content or content == "" then
            data = {snippets = {}}
            file:write(json.encode(data))
        end

        file:close()
    else
        open_error()
    end
end

function Data.read()
    local file = io.open("data.json", "r")
    local content
    local data

    if file then
        content = file:read("*a")

        if content and content ~= "" then
            data = json.decode(content)
        end

        file:close()
    else
        open_error()
    end

    return data
end

function Data.write(array)
    local file = io.open("data.json", "w")
    local data

    if file then
        data = json.encode(array)

        file:write(data)

        file:close()
    else
        open_error()
    end
end

function Data.append(value)
    local array = Data.read()
    local file = io.open("data.json", "w")
    local data

    if file then
        table.insert(array.snippets, value)

        data = json.encode(array)

        file:write(data)

        file:close()
    else
        open_error()
    end
end

return Data