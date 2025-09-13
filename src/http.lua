local socket = require("socket")

local M = {}

--+ REQUEST +--
local Request = {}
Request.__index = Request

function Request.new(method, path, body, headers)
    local i = setmetatable({}, Request)

    i.headers = {
        ["User-Agent"] = "luapi/0.0-1",
        ["Content-Length"] = body and tostring(#body) or 0
    }

    for k, v in pairs(headers or {}) do
        i.headers[k] = v
    end

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
    self.path = type(path) == "string" and path or "/"
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

    local head, body = raw:match("^(.-)\r\n\r\n(.*)$")
    if not head then
        head, body = raw, ""
    end

    local protocol, status_code, status_msg = head:match("^(HTTP/%d%.%d) (%d+) (.-)\r?\n")
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
    local scheme, host, port, path = parse_url(url)

    if scheme ~= "http" then
        return
    end

    local s, err = socket.tcp()
    if not s then return end
    s:settimeout(5)

    local ok, err = s:connect(host, port)
    if not ok then
        s:close(); return
    end

    local req = Request.new(method, path, body, headers)
        :add_header("Host", host)
        :build()

    s:send(req)

    local header_data = {}
    while true do
        local line, err = s:receive("*l")
        if not line then return end
        if line == "" then break end
        table.insert(header_data, line)
    end

    local received_headers = table.concat(header_data, "\r\n")
    local content_length = received_headers:match("Content%-Length:%s*(%d+)")
    content_length = tonumber(content_length or 0)

    local received_body = ""
    if content_length > 0 then
        received_body, err = s:receive(content_length)
        if not received_body then return end
    end

    local raw = table.concat({ table.concat(header_data, "\r\n"), "", received_body }, "\r\n")

    s:close()

    local res = Response.new(raw)
    return res:get_status_code(), res:get_headers(), res:get_body()
end

return M
