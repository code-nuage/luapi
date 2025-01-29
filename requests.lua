if not require("cURL") then
	error("Lua-cURL is a necessary dependencie. Install it with 'luarocks install lua-curl'")
end

local cURL = require("cURL")

local Requests = {}

local function perform_request(url, method, data, headers)
    local response = {}

    local c = cURL.easy{
        url = url,
        customrequest = method,
        writefunction = function(data)
            table.insert(response, data)
            return true
        end
    }

    if headers then
        c:setopt(cURL.OPT_HTTPHEADER, headers)
    end

    if data and (method == "POST" or method == "PUT" or method == "PATCH") then
        c:setopt(cURL.OPT_POSTFIELDS, data)
    end

    c:perform()

	local code = c:getinfo(cURL.INFO_RESPONSE_CODE)

    c:close()

    return code, table.concat(response)
end

function Requests.GET(url)
	return perform_request(url, "GET", nil, nil)
end

function Requests.POST(url, data)
	return perform_request(url, "POST", data, {"Content-Type: application/json"})
end

function Requests.PUT(url, data)
	return perform_request(url, "PUT", data, {"Content-Type: application/json"})
end

function Requests.DELETE(url)
	return perform_request(url, "DELETE", nil, nil)
end

function Requests.PATCH(url)
	return perform_request(url, "PATCH", '{"status": "active"}', {"Content-Type: application/json"})
end

function Requests.OPTIONS(url)
	return perform_request(url, "OPTIONS", nil, nil)
end

function Requests.HEAD(url)
	return perform_request(url, "HEAD", nil, nil)
end

return Requests