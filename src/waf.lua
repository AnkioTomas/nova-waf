local localCache = require "cache"

-- 检查是否为白名单IP
local function isWhiteIp(ip)
    if WHITE_IPS[ip] then
        return true
    end
    return false
end

-- 检查是否为黑名单IP
local function isBlackIp(ip)
    if BLACK_IPS[ip] then
        return true
    end
    return false
end

-- 检查是否为被封禁的IP
local function isBlockedIp(ip)
    -- 从缓存中检查是否存在封禁记录
    local value, err = localCache.cacheGet("block:" .. ip)
    if value then
        return true
    end
    return false
end

-- 返回403状态码及相关信息
local function ret403(msg)
    -- 判断WAF配置中是否开启拦截模式
    if WAF_CONFIG["mode"] == "monitor" then
        return
    end
    -- 读取403页面内容
    local file = io.open(CURRENT_PATH .. "conf.d/403.html", "r")
    local content = file:read("*all")
    file:close()
    
    -- 设置响应头和替换页面内容中的占位符
    ngx.header.content_type = "text/html"
    ngx.status = ngx.HTTP_FORBIDDEN
    -- content = string.gsub(content, "{BLOCK_REASON}", msg)
    if DEBUG then
        content = msg
    else 
        content = string.gsub(content, "{BLOCK_REASON}", msg)     
    end

    -- content = msg
    ngx.say(content)
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

-- 记录请求信息到日志文件
local function recordRequest(ip, rule, body,level,desc)
    -- 构建日志文件路径
    local log = WAF_CONFIG["log_path"]  .. os.date("%Y-%m-%d").. ip .. ".log"
    -- 打开日志文件
    local logger = require "logger"
    local cjson = require "cjson"
    local hostLogger = logger:new(WAF_CONFIG["log_path"],ip,true)
    -- 构建日志内容
    local logTable = {
        request_id = ngx.var.request_id,
        attack_type = rule,
        ip = ip,
        request_time = ngx.var.request_time,
        http_method = ngx.var.request_method,
        server = ngx.var.server_name,
        request_uri = ngx.var.request_uri,
        request_protocol = ngx.var.server_protocol,
        request_data = body,
        user_agent = ngx.var.http_user_agent,
        headers = ngx.req.get_headers(),
        level = level,
        desc = desc
    }
    local logStr, err = cjson.encode(logTable)
    if logStr then
        hostLogger:log(logStr .. '\n')
    else
        ngx.log(ngx.ERR, "failed to encode json: ", err)
    end
end

-- 检查是否发生攻击行为，并进行相应处理
local function inAttack(ip, rule, body,level,desc)
    -- 记录请求到日志
    recordRequest(ip, rule, body,level,desc)

    -- 查询缓存中的攻击情况
    local value, err = localCache.cacheGet("attack:" .. ip)
    if value then
        -- 如果请求次数超过阈值，封禁IP
        if tonumber(value) > tonumber( WAF_CONFIG["block_count"]) then
            localCache.cacheSet("block:" .. ip, 1, WAF_CONFIG["block_timeout"])
            localCache.cacheDelete("attack:" .. ip)
            return
        end
        -- 请求次数加1
        localCache.cacheIncr("attack:" .. ip, WAF_CONFIG["attack_timeout"])
    else
        -- 第一次请求，设置请求次数为1
        localCache.cacheSet("attack:" .. ip, 1, WAF_CONFIG["attack_timeout"])
    end
end

-- 递归解码URI，防止恶意编码攻击
local function recursive_unescape_uri(ip, uri, max_attempts)
    local decoded_uri = uri
    local prev_decoded_uri = ""
    local attempts = 0

    -- 循环直到前后两次解码结果相同或者达到最大解码次数
    while decoded_uri ~= prev_decoded_uri and attempts < max_attempts do
        prev_decoded_uri = decoded_uri
        -- 使用 ngx.unescape_uri 进行全局解码
        decoded_uri = ngx.unescape_uri(decoded_uri)
        attempts = attempts + 1
    end

    -- 如果超过最大解码次数，则认为存在恶意行为
    if attempts >= max_attempts then
        return nil
    end

    return string.lower(decoded_uri)
end

local function calculateRequestSize()
    -- 获取请求头大小
    local headers_size = 0
    local headers = ngx.req.get_headers()
    for k, v in pairs(headers) do
        headers_size = headers_size + #k
        if type(v) == "table" then
            for _, vv in ipairs(v) do
                headers_size = headers_size + #vv
            end
        else
            headers_size = headers_size + #v
        end
    end

    -- 获取请求体大小
    local body_length = tonumber(ngx.var.content_length) or 0

    -- 计算HTTP方法、URI等的大小
    local method_size = #ngx.req.get_method()
    local uri_size = #ngx.var.request_uri

    -- 计算整个请求大小
    local total_size = headers_size + body_length + method_size + uri_size
    return total_size
end

-- 是否为超大请求
local function isBigRequest(ip)
    local body_size = calculateRequestSize()
    local max_body_size = tonumber( WAF_CONFIG["body_max_size"]) or 1024 * 1024
    -- 如果请求体过大，则拒绝请求
    if body_size > max_body_size then
        return true
    end
    return false
end

local function print_table(t, indent)
    indent = indent or 0
    local prefix = string.rep("  ", indent)
    for k, v in pairs(t) do
        if type(k) == "number" then
            k = "-"  -- 用 '-' 来表示列表项
        end
        if type(v) == "table" then
            ngx.log(ngx.INFO,prefix .. k .. ":")
            print_table(v, indent + 1)
        else
            ngx.log(ngx.INFO,prefix .. k .. ": " .. tostring(v))
        end
    end
end
local function regex_to_lua_pattern(regex)
    local lua_pattern = regex

    -- Escape Lua pattern special characters
    lua_pattern = lua_pattern:gsub("%%", "%%%%")
    lua_pattern = lua_pattern:gsub("%^", "%%^")
    lua_pattern = lua_pattern:gsub("%$", "%%$")
    lua_pattern = lua_pattern:gsub("%(", "%%(")
    lua_pattern = lua_pattern:gsub("%)", "%%)")
    lua_pattern = lua_pattern:gsub("%.", "%%.")
    lua_pattern = lua_pattern:gsub("%[", "%%[")
    lua_pattern = lua_pattern:gsub("%]", "%%]")
    lua_pattern = lua_pattern:gsub("%*", "%%*")
    lua_pattern = lua_pattern:gsub("%+", "%%+")
    lua_pattern = lua_pattern:gsub("%-", "%%-")
    lua_pattern = lua_pattern:gsub("%?", "%%?")
    
    -- Convert common regex patterns to Lua patterns
    lua_pattern = lua_pattern:gsub("\\d", "%d")
    lua_pattern = lua_pattern:gsub("\\D", "[^%d]")
    lua_pattern = lua_pattern:gsub("\\w", "%w")
    lua_pattern = lua_pattern:gsub("\\W", "[^%w]")
    lua_pattern = lua_pattern:gsub("\\s", "%s")
    lua_pattern = lua_pattern:gsub("\\S", "[^%s]")
    
    return lua_pattern
end

-- 检查请求是否符合规范，包括大小和解码
local function attack(ip)
    local max_decode_count = tonumber(WAF_CONFIG["decode_max_count"]) or 10
    -- 获取请求方法和URI
    local method = ngx.req.get_method()
    local uri = ngx.var.request_uri

    -- 将所有的uri加入检测数组
    local checkData = {}

    -- 解码URI，最多解码次数，防止恶意编码攻击
    uri = recursive_unescape_uri(ip, uri, max_decode_count)
    table.insert(checkData, uri)
   

    -- 获取请求头和请求体
    local headers = ngx.req.get_headers()

    for k, v in pairs(headers) do
        local header = k .. ": " .. v
        header = recursive_unescape_uri(ip, header, max_decode_count)
        table.insert(checkData, header)
    end

    ngx.req.read_body()
    local body = ngx.req.get_body_data() or ""

    -- 解码请求体
    body = recursive_unescape_uri(ip, body,max_decode_count)
    table.insert(checkData, body)

    for _, data in ipairs(checkData) do
        if data == nil then
            ngx.log(ngx.INFO, "Attack detected: ", "恶意编码")
            inAttack(ip, "恶意编码", "恶意编码","low","恶意编码")
            ret403("恶意编码")
            
            return
        else
                 -- 检查是否包含恶意字符
             --    print_table(RULE_FILES)         
        for key, rule in pairs(RULE_FILES) do
        
            for _, pattern in pairs(rule.rules) do
        
                if ngx.re.match(data, pattern, "isjo") then
                    ngx.log(ngx.INFO, "Attack detected: ", rule.name,"=>",rule.desc)
                   
                    inAttack(ip,rule.name, data,rule.level,rule.desc)
                    ret403("攻击行为: "..rule.name.." => "..pattern)
                    return
                end
            end
        end    
        end
       
    end

    -- TODO: 进行进一步的攻击检测和防护

end

-- WAF主函数，用于检查请求并进行相应处理
local function waf()
    -- 检查WAF配置是否开启
    if WAF_CONFIG["mode"] == "off" then
        ngx.log(ngx.INFO, "WAF is off")
        return
    end

    -- 获取客户端IP地址
    local ip = require "ip"
    local ipAddr = ip.getClientIP()
    ngx.log(ngx.INFO, "IP: ", ipAddr)

    -- 检查是否为被封禁IP
    if isBlockedIp(ipAddr) then
        ngx.log(ngx.INFO, "Blocked IP")
        ret403("您的IP已被封禁")
        return
    end

    -- 检查是否为白名单IP
    if isWhiteIp(ipAddr) then
        ngx.log(ngx.INFO, "White IP")
        return
    end

    -- 检查是否为黑名单IP
    if isBlackIp(ipAddr) then
        ngx.log(ngx.INFO, "Black IP")
        ret403("黑名单IP")
        return
    end
    -- 检测是否为超大请求
    if isBigRequest(ipAddr) then
        ngx.log(ngx.INFO, "Body size too large")
        inAttack(ip, "请求体过大", "请求体过大","low","请求体过大")
        ret403("请求体过大")
        return
    end

    -- 检查请求是否存在攻击行为
    attack(ipAddr)
end

-- 执行WAF主函数
waf()
