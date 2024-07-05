local red = require "redis"
function isWhiteIp(ip)
    if WHITE_IPS[ip] then
        return true
    end
    return false
end

function isBlackIp(ip)
    if BLACK_IPS[ip] then
        return true
    end
    return false
end


function isBlockedIp(ip)
    -- 检查redis里面是否ban了这个ip
    local value, err = red.redisGet("block:" .. ip)
    if value then
        return true
    end
    return false
end

function ret403(msg)
    -- 从conf.d/403.html 读取内容
    local file = io.open(CURRENT_PATH .. "conf.d/403.html", "r")
    local content = file:read("*all")
    file:close()
    ngx.header.content_type = "text/html"
    -- 替换{BLOCK_REASON}
    content = string.gsub(content, "{BLOCK_REASON}", msg)
    ngx.say(content)
    ngx.exit(ngx.HTTP_FORBIDDEN)
end


function recordRequest(ip,rule,body)
    -- 记录请求到日志，包含触发规则/请求时间/请求IP/请求方法/请求URI/请求头/请求体
    local log = WAF_CONFIG["log_path"]  .. os.date("%Y-%m-%d").. ip .. ".log"
    local file = io.open(log, "a")
    local startKey = "----------start---------"
    local endKey = "----------end---------"
    file:write(startKey .. "\n")
    file:write("Time: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
    file:write("IP: " .. ip .. "\n")
    file:write("Rule: " .. rule .. "\n")
    file:write("Method: " .. ngx.req.get_method() .. "\n")
    file:write("URI: " .. ngx.var.request_uri .. "\n")
    file:write("Headers: \n")
    local headers  = ngx.req.get_headers()
    for k, v in pairs(headers) do
        file:write(k .. ": " .. v .. "\n")
    end
    file:write("Body: \n")
    file:write(body .. "\n")    
    file:write(endKey .. "\n\n")
    file:close()

    -- 删除过期的日志文件夹
    local cmd = "find " .. WAF_CONFIG["log_path"] .. " -type d -mtime +" .. WAF_CONFIG["log_expire"] .. " -exec rm -rf {} \\;"
    os.execute(cmd)
end


function inAttack(ip,rule)
    recordRequest(ip,rule)
    -- redis查询这个ip的请求情况
    local value, err = red.redisGet("attack:" .. ip)
    if value then
        -- 如果请求次数超过阈值，封禁ip
        if tonumber(value) > WAF_CONFIG["block_count"] then
            red.redisSet("block:" .. ip, "1", WAF_CONFIG["block_timeout"])
            return
        end
        -- 请求次数加1
        red.redisSet("attack:" .. ip, value + 1, WAF_CONFIG["attack_timeout"])
    else
        -- 第一次请求，设置请求次数为1
        red.redisSet("attack:" .. ip, 1, WAF_CONFIG["attack_timeout"])
    end
end
 function recursive_unescape_uri(ip,uri, max_attempts)
    local decoded_uri = uri
    local prev_decoded_uri = ""
    local attempts = 0

    -- 循环直到前后两次解码结果相同或者达到最大解码次数
    while decoded_uri ~= prev_decoded_uri and attempts < max_attempts do
        prev_decoded_uri = decoded_uri
        -- 使用 string.gsub 进行全局替换解码
        decoded_uri = ngx.unescape_uri(decoded_uri)
        attempts = attempts + 1
    end

    -- 如果超过最大解码次数，则认为存在恶意行为
    if attempts >= max_attempts then
        ngx.log(ngx.WARN, "Possible malicious URI with excessive decoding attempts: ", uri)
        ret403("存在恶意编码行为")
        -- TODO 记录日志
        inAttack(ip, "Body size too large", "")
        return nil
    end

    return decoded_uri
end

function attack(ip)
    ngx.req.read_body()
    local body_size = ngx.req.get_body_length()
    local max_body_size = WAF_CONFIG["body_max_size"]
    if body_size > max_body_size then
        ngx.log(ngx.INFO, "Body size too large")
        ret403("请求体过大")
        inAttack(ip, "Body size too large", "Body size too large")
        return
    end

    local method = ngx.req.get_method()
    -- 获取请求的URI
    local uri = ngx.var.request_uri
    -- 进行url解码
    uri = ngx.unescape_uri(uri)



    -- 获取请求头
    local headers = ngx.req.get_headers()
    -- 获取请求体大小
    local body = ngx.req.get_body_data()
    -- 获取请求体


end


function waf()
    -- check WAF config
    if WAF_CONFIG["mode"] == "off" then
        ngx.log(ngx.INFO, "WAF is off")
        return
    end
    
    
    local ip = require "ip"
    local ipAddr = ip.getClientIP()
    ngx.log(ngx.INFO, "IP: ", ipAddr)
    -- check isBlockedIp
    if isBlockedIp(ipAddr) then
        ngx.log(ngx.INFO, "Blocked IP")
        ret403("您的IP已被封禁")
        return
    end
    -- check isWhiteIp
    if isWhiteIp(ipAddr) then
        ngx.log(ngx.INFO, "White IP")
        return
    end
    -- check isBlackIp
    if isBlackIp(ipAddr) then
        ngx.log(ngx.INFO, "Black IP")
        ret403("黑名单IP")
        return
    end    
    
    -- check attack
    attack(ipAddr)


end


