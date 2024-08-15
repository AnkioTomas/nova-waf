local localCache = require "cache"
local localCount = require "count"
local Waf = {
    
}
Waf.__index = Waf

-- Constructor
function Waf:new()
    local ip = require "ip"
    local ipAddr = ip.getClientIP()
    local instance = {
        ip = ipAddr,
        key_block = "block:" .. ipAddr,
        key_possibly = "possibly:" .. ipAddr,
        key_attack = "attack:" .. ipAddr,
        key_attack_count = "attackCount:" .. ipAddr,
        key_cc = "cc:" .. ipAddr,
       
        possibly_timeout = tonumber(WAF_CONFIG["possibly_timeout"]) or 300,
        possibly_count = tonumber(WAF_CONFIG["possibly_count"]) or 10,
        block_count = tonumber(WAF_CONFIG["block_count"]) or 10,
        block_time = tonumber(WAF_CONFIG["block_time"]) or 600,
        block_timeout = tonumber(WAF_CONFIG["block_timeout"]) or 600,
        cache = localCache:new(),
        count = localCount:new()
     }
    setmetatable(instance, self)
    return instance
end

function Waf:isWhiteIp()
    if WHITE_IPS[self.ip] then
        return true
    end
    return false
end

function Waf:isBlackIp()
    if BLACK_IPS[self.ip] then
        return true
    end
    return false
end

function Waf:isBlockedIp()
    local value, err = self.cache:cacheGet(self.key_block)
    if value then
        return true
    end
    return false
end

function Waf:ret403(msg)
    self.count:addReqDenyCount()
    local file = io.open(CURRENT_PATH .. "conf.d/403.html", "r")
    local content = file:read("*all")
    file:close()
    
    ngx.header.content_type = "text/html"
    ngx.status = ngx.HTTP_FORBIDDEN
    content = string.gsub(content, "{BLOCK_REASON}", msg)
    if WAF_CONFIG["debug"] == "on" then
        ngx.say(msg)
    else 
        ngx.say(content)    
    end
    
    ngx.exit(ngx.HTTP_FORBIDDEN)
end

function Waf:recordRequest(rule, body)
    local logger = require "logger"
    local cjson = require "cjson"
    local hostLogger = logger:new(self.ip)
    local logTable = {
        request_id = ngx.var.request_id,
        attack_type = rule,
        ip = self.ip,
        request_time = ngx.var.request_time,
        http_method = ngx.var.request_method,
        request_uri = ngx.var.request_uri,
        request_protocol = ngx.var.server_protocol,
        request_data = body,
        user_agent = ngx.var.http_user_agent,
        headers = ngx.req.get_headers()
    }
    local logStr, err = cjson.encode(logTable)
    if logStr then
        hostLogger:log(logStr .. '\n')
    else
        ngx.log(ngx.ERR, "failed to encode json: ", err)
    end
end

function Waf:blockIp(attackCount)
  -- debug 模式下不进行IP封锁
    if WAF_CONFIG["debug"] == "on" then
        return true
    end
    -- 在相当长的一段时间内如果又发生IP封禁行为，将会延长封禁时间
    self.cache:cacheSet(self.key_block, 1, self.block_timeout * attackCount)
    self.cache:cacheDel(self.key_possibly)
    self.cache:cacheDel(self.key_attack)
    -- 记录在100分钟内的攻击次数，用于提高封禁时间
    self.cache:cacheSet(self.key_attack_count,attackCount, self.block_timeout * 10)
    ngx.log(ngx.INFO, "Block IP: ", self.ip, " for ", self.block_timeout * attackCount, " seconds")
end

function Waf:inAttack(rule, body, level, desc, possibly)

    self:recordRequest(rule, body)
  
    -- 监控模式下不拦截请求
    if WAF_CONFIG["mode"] == "monitor" then
        return false
    end

    -- 连续攻击封禁IP
    local attackCount, err = tonumber(self.cache:cacheGet(self.key_attack_count) or 0)
    ngx.log(ngx.INFO, self.ip, " attackCount: ", attackCount)
    if attackCount > 0 then
        -- 只要之前有一次攻击，并且被检测到存在攻击行为，就会封禁IP
        self:blockIp(attackCount)
        return true
    end
    attackCount = attackCount + 1
    -- 置信度高的攻击直接封禁IP
    local total = possibly
    local value, err = tonumber(self.cache:cacheGet(self.key_possibly) or 0)
    total = possibly + value

    ngx.log(ngx.INFO, self.ip, " possibly: ", total)

    self.cache:cacheSet(self.key_possibly, total, self.possibly_timeout)
    if total < tonumber(self.possibly_count) then
        return false
    end

    -- 攻击次数超过阈值，封禁IP
    value = tonumber(self.cache:cacheGet(self.key_attack) or 1)
    self.cache:cacheSet(self.key_attack,value + 1, self.block_time)
    ngx.log(ngx.INFO, self.ip, " attack: ", value)

    if value > self.block_count then
        self:blockIp(attackCount)
        return true
    end
    return false
end

function Waf:isBigRequest()
    local body_size = self:calculateRequestSize()
    local max_body_size = tonumber(WAF_CONFIG["body_max_size"]) or 1024 * 1024
    if body_size > max_body_size then
        return true
    end
    return false
end


function Waf:isCCAttack()
    if WAF_CONFIG["cc_defence"] == "off" then
        return false
    end
    local limit = tonumber(WAF_CONFIG["cc_limit"]) or 100
    local seconds = tonumber(WAF_CONFIG["cc_seconds"]) or 60

    local key = self.key_cc
    local value = tonumber(self.cache:cacheGet(key) or 0)
    local count = value + 1
    if count > limit then
        return true
    end
    self.cache:cacheSet(key,count, seconds)
    return false
end

function Waf:UnEscapeUri(uri, max_attempts)
    local decoded_uri = uri
    local prev_decoded_uri = ""
    local attempts = 0
    while decoded_uri ~= prev_decoded_uri and attempts < max_attempts do
        prev_decoded_uri = decoded_uri
        decoded_uri = ngx.unescape_uri(decoded_uri)
        attempts = attempts + 1
    end

    if attempts >= max_attempts then
        return nil
    end


 
    local decoded_uri_2 = decoded_uri
    prev_decoded_uri = ""
    attempts = 0
    -- 解码字符实体的函数
    while decoded_uri_2 ~= prev_decoded_uri and attempts < max_attempts do
        prev_decoded_uri = decoded_uri_2
        local new_decoded_uri, _, err = ngx.re.gsub(decoded_uri_2, "&#(\\d+);", function(m)
            return string.char(tonumber(m[1]))
        end, "jo")
    
        if not new_decoded_uri then
            ngx.log(ngx.ERR, "Error during regex substitution: ", err)
            return nil
        end
    
        decoded_uri_2 = new_decoded_uri
        attempts = attempts + 1
    end

    if attempts >= max_attempts then
        return nil
    end

    return string.lower(decoded_uri_2)
end

function Waf:trim(s)
    ngx.log(ngx.INFO, "Trim: ", s)
    return s:match("^%s*(.-)%s*$")
end
  

function Waf:attack()
    local max_decode_count = tonumber(WAF_CONFIG["decode_max_count"] or 10)
    local method = ngx.req.get_method()
    local uri = ngx.var.request_uri
    local checkData = {}

    uri = self:UnEscapeUri(uri, max_decode_count)
    table.insert(checkData, "uri: "..uri)
    local headers = ngx.req.get_headers()

    for k, v in pairs(headers) do
        local header = k .. ": " .. v
        header = self:UnEscapeUri(header, max_decode_count)
        table.insert(checkData, header)
    end

    ngx.req.read_body()
    local body = ngx.req.get_body_data() or ""
    body = self:UnEscapeUri(body, max_decode_count)
    table.insert(checkData, "body: "..body)

    for _, data in ipairs(checkData) do
        if data == nil then
            ngx.log(ngx.INFO, "Attack detected: ", "Malicious encoding")
            if self:inAttack("Malicious encoding", "Malicious encoding", "low", "Malicious encoding", 5) then
                self:ret403("Malicious encoding")
                return
            end
        else
            for key, rule in pairs(RULE_FILES) do
                for _, patternItem in pairs(rule.rules) do
                   
                    local positions = {}

-- 使用 string.gmatch 分割字符串
                    for part in string.gmatch(pos, '([^,]+)') do
                        table.insert(positions, part)
                    end

-- 现在 positions 是一个包含各部分的表
-- 例如: positions = {"abc", "def", "ghi"}

-- 在你的逻辑中使用分割后的部分
                    for _, p in ipairs(positions) do
                        if data:sub(1, #p) == p then
                            local regex = string.lower(patternItem.pattern):match("^%s*(.-)%s*$")
                            if ngx.re.match(data, regex, "isjo") then
                                if self:inAttack(rule.name .. " - " .. patternItem.name, body, rule.level, rule.desc, patternItem.confidence) then
                                    if WAF_CONFIG["debug"] == "on" then
                                        self:ret403("Attack detected: " .. rule.name .. " - " .. patternItem.name .. " => " .. regex .. " [TEXT] => " .. data)
                                    else
                                        self:ret403("Attack detected.")
                                    end    
                                    return
                                end
                            end
                            
                        end
                    end    
                            

                end
            end
        end
    end
end

function Waf:calculateRequestSize()
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

    local body_length = tonumber(ngx.var.content_length) or 0
    local method_size = #ngx.req.get_method()
    local uri_size = #ngx.var.request_uri

    local total_size = headers_size + body_length + method_size + uri_size
    return total_size
end

function Waf:process()
    if WAF_CONFIG["mode"] == "off" then
        ngx.log(ngx.INFO, "WAF is off")
        return
    end

    self.count:addReqCount(self.ip)

    if self:isCCAttack() then
        ngx.log(ngx.WARN, "CC Attack")
        
        self:ret403("CC Attack")
        return
    end

    if self:isBlockedIp() then
        ngx.log(ngx.WARN, "Blocked IP")
        self:ret403("Your IP has been blocked")
        return
    end

    if self:isWhiteIp() then
        ngx.log(ngx.WARN, "White IP")
        return
    end

    if self:isBlackIp() then
        ngx.log(ngx.WARN, "Black IP")
        self:ret403("Your IP has been blacklisted")
        return
        end

    if self:isBigRequest() then
        ngx.log(ngx.WARN, "Big request")
        self:ret403("Request body is too large")
        return
    end

    self:attack()
end




local myWaf = Waf:new()
myWaf:process()
