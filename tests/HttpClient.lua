local socket = require("socket")
local http = require("socket.http")
local ltn12 = require("ltn12")
local mime = require("mime")

local HttpClient = {}
HttpClient.__index = HttpClient

function HttpClient:new()
    local instance = {
        headers = {}
    }
    setmetatable(instance, HttpClient)
    return instance
end

function HttpClient:set_header(name, value)
    self.headers[name] = value
end

function HttpClient:send_request(url, method, body)
    local response_body = {}
    
    local res, code, response_headers, status = http.request{
        url = url,
        method = method,
        headers = self.headers,
        source = body and ltn12.source.string(body) or nil,
        sink = ltn12.sink.table(response_body)
    }

    return {
        status = status,
        code = code,
        headers = response_headers,
        body = table.concat(response_body)
    }
end

function HttpClient:get(url)
    return self:send_request(url, "GET")
end

function HttpClient:post(url, body)
    self:set_header("Content-Type", "application/x-www-form-urlencoded")
    return self:send_request(url, "POST", body)
end

function HttpClient:put(url, body)
    self:set_header("Content-Type", "application/x-www-form-urlencoded")
    return self:send_request(url, "PUT", body)
end

function HttpClient:head(url)
    return self:send_request(url, "HEAD")
end

function HttpClient:upload_file(url, file_path, file_param_name)
    local boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
    self:set_header("Content-Type", "multipart/form-data; boundary=" .. boundary)
    
    local file = io.open(file_path, "rb")
    local file_content = file:read("*all")
    file:close()

    local body = "--" .. boundary .. "\r\n" ..
        'Content-Disposition: form-data; name="' .. file_param_name .. '"; filename="' .. file_path .. '"\r\n' ..
        "Content-Type: application/octet-stream\r\n\r\n" ..
        file_content .. "\r\n" ..
        "--" .. boundary .. "--\r\n"
    
    return self:send_request(url, "POST", body)
end

return HttpClient
