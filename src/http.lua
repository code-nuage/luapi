local socket = require("socket")

local M = {}

--+ REQUEST +--
local Request = {}
Request.__index = Request

function Request.new(method, path, body, headers)
    local i = setmetatable({}, Request)

    i.headers = {
        ["User-Agent"] = "luapi/0.0-1"
    }

    i:set_method(method or "GET")
        :set_path(path or "/")
        :set_body(body or "")

    return i
end

-- SETTERS
function Request:set_method(method)
    self.method = type(method) == "string" and method or "GET"
    return self
end

function Request:set_path(path)
    self.method = type(path) == "string" and path or "/"
    return self
end

function Request:add_header(key, value)
    self.headers[key] = value
    return self
end

function Request:set_body(body)
    self.body = type(body) == "string" and body or ""
    return self
end

-- GETTERS
function Request:get_method()
    return self.method or "GET"
end

function Request:get_path()
    return self.path or "/"
end

function Request:get_headers()
    return self.headers or {}
end

function Request:get_body()
    return self.body or ""
end

function Request:build()
    local headers = ""

    for k, v in pairs(self:get_headers()) do
        headers = headers .. k .. ": " .. v .. "\r\n"
    end

    local text = string.format("%s %s HTTP/1.1\r\n%s\r\n%s",
        self:get_method(),
        self:get_path(),
        headers,
        self:get_body())
    return text
end

--+ RESPONSE +--
local Response = {}
Response.__index = Response

function Response.new(raw)
    local i = setmetatable({}, Response)

    local head, body = raw:match("^(.-\r\n)\r\n(.*)$")
    if not head then
        head, body = raw, ""
    end

    local protocol, status_code, status_msg = head:match("^(HTTP/%d%.%d) (%d+) (.-)\r\n")
    i.protocol = protocol or ""
    i.status_code = tonumber(status_code) or 0
    i.status_msg = status_msg or ""

    i.headers = {}
    for k, v in head:gmatch("([%w-]+):%s*(.-)\r\n") do
        i.headers[k] = v
    end

    i.body = body or ""

    return i
end

-- GETTERS
function Response:get_protocol()
    return self.protocol
end

function Response:get_status_code()
    return self.status_code
end

function Response:get_status_message()
    return self.status_msg
end

function Response:get_headers()
    return self.headers
end

function Response:get_body()
    return self.body
end

local function parse_url(url)
    local scheme, host, port, path = url:match("^(https?)://([^:/]+):?(%d*)(/?.*)$")
    if not scheme then
        return nil, nil, nil, nil, "invalid URL"
    end
    if path == "" then path = "/" end
    if port == "" then
        port = (scheme == "https") and "443" or "80"
    end
    return scheme, host, tonumber(port), path
end

function M.perform(url, method, body, headers)
    local scheme, host, path, port = parse_url(url)
    local s, err = socket.tcp()
    if not s then return nil, err end

    s:settimeout(5)

    print(host, port)

    local ok, err = s:connect(host, port)
    if not ok then s:close(); return nil, err end

    local req = Request.new(method, path, body, headers):add_header("Host", host):build()

    s:send(req)

    local response, chunk = {}, nil
    while true do
        chunk, err = s:receive(1024)
        if chunk and #chunk > 0 then
        table.insert(response, chunk)
        else
        break
        end
    end

    s:close()
    return table.concat(response)
end

return M
