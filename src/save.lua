local cjson = require("cjson")
local lfs = require("lfs")

local colors = require("colors")

local M = {}

function M.mkdir_p(path)
    local sep = "/"

    local parts = {}
    for part in string.gmatch(path, "[^" .. sep .. "]+") do
        table.insert(parts, part)
    end

    local current = (string.sub(path, 1, 1) == sep) and sep or ""
    for _, part in ipairs(parts) do
        current = current .. part .. sep
        local attr = lfs.attributes(current)
        if not attr then
            local ok, err = lfs.mkdir(current)
            if not ok then
                return false, err
            end
        elseif attr.mode ~= "directory" then
            return false, current .. " exists but is not a directory"
        end
    end
    return true
end

function M.save(path, data)
    local file, err = io.open(path, "w+")
    if not file then
        return false, err
    end
    local ok, json_data = pcall(cjson.encode, data)
    if not ok or not (type(json_data) == "string") then
        return false, "JSON encode error"
    end
    file:write(json_data)
    file:close()
    return true
end

function M.load(path)
    local file, err = io.open(path, "r")
    if not file then
        return false, err
    end
    local json_data = file:read("*a")
    file:close()
    local ok, data = pcall(cjson.decode, json_data)
    if not ok or not (type(data) == "table") then
        return false, "JSON decode error"
    end
    return true, data
end

return M
