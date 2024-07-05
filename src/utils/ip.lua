-- Apache License, Version 2.0 (http://www.apache.org/licenses/LICENSE-2.0)
-- Copyright (c) 2023 bukale bukale2022@163.com

local _M = {}



local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local find = string.find
local sub = string.sub
local ngxmatch = ngx.re.match

local insert = table.insert
 -- 去除字符串两端空白字符的 trim 函数
 local function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end
function _M.getClientIP()
    local var = ngx.var
    local ips = {
        var.http_x_forwarded_for,
        var.remote_addr
    }

    for _, ip in pairs(ips) do
        if ip and #ip > 0 then
            local idx = find(ip, ",")
            if idx and idx > 0 then
                ip = sub(ip, 1, idx - 1)
            end

            return trim(ip)
        end
    end

    return "unknown"
end

-- 是否内网IP
function _M.isPrivateIP(ip)
    if not ip then
        return false
    end

    -- Check for loopback IPs and localhost
    if ip == '127.0.0.1' or ip == '::1' or ip == 'localhost' then
        return true
    end

    -- Check for IPv4 private IP ranges
    local ipv4_match = ngxmatch(ip, '^(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})$', 'isjo')
    if ipv4_match then
        local a, b, c, d = tonumber(ipv4_match[1]), tonumber(ipv4_match[2]), tonumber(ipv4_match[3]), tonumber(ipv4_match[4])
        if a == 10 then
            return true
        elseif a == 172 and b >= 16 and b <= 31 then
            return true
        elseif a == 192 and b == 168 then
            return true
        elseif a == 100 and b >= 64 and b <= 127 then  -- Carrier-Grade NAT (CGNAT)
            return true
        elseif a == 169 and b == 254 then  -- Link-local address
            return true
        end
    end

    -- Check for IPv6 private IP ranges (unique local addresses)
    local ipv6_match = ngxmatch(ip, '^([a-fA-F0-9:]+)$', 'isjo')
    if ipv6_match then
        if ngxmatch(ip, '^fc[0-9a-fA-F]{2}::', 'isjo') or ngxmatch(ip, '^fd[0-9a-fA-F]{2}::', 'isjo') then
            return true
        end
    end

    return false
end

local bit = require("bit")

function _M.ip2number(ip)
    local o1, o2, o3, o4 = ip:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")
    return 2^24*o1 + 2^16*o2 + 2^8*o3 + o4
end

function _M.number2ip(number)
    local o1 = bit.rshift(number, 24) % 256
    local o2 = bit.rshift(number, 16) % 256
    local o3 = bit.rshift(number, 8) % 256
    local o4 = number % 256
    return string.format("%d.%d.%d.%d", o1, o2, o3, o4)
end

function _M.parseCidr(cidr)
    local ip, prefix = cidr:match("(%d+%.%d+%.%d+%.%d+)/(%d+)")
    local start_ip = _M.ip2number(ip)
    local num_ips = bit.lshift(1, 32 - prefix)

    local ips = {}
    for i = 0, num_ips - 1 do
        table.insert(ips,  _M.number2ip(start_ip + i))
    end
    return ips
end

return _M