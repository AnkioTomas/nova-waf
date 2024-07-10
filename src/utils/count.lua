local concat = table.concat
local timerat = ngx.timer.at
local localCache = require "cache"
local lock = require("resty.lock")
local _M = {}
_M.__index = _M

-- 创建新的日志对象
function _M:new()
    local t = {
       KEY_PREFIX = "count_", 
       REQ_COUNT = "reqCount",
       REQ_DENY_COUNT = "reqDenyCount",
       LAST_DAY = "lastDay",
       LAST_DAY_HOUR = "lastDayHour",
       LOCK_KEY = "count_lock",
       cache = localCache:new("nova_waf_count"),
       lock = localCache:new("dict_locks")
    }

    setmetatable(t, self)
    return t
end

-- 函数用于判断是否为爬虫
local function is_crawler(ua)
    -- 常见爬虫的关键字匹配
    local crawlers = {
        "bot", "spider", "crawler", "slurp", "archiver", "search", "agent"
    }

    for _, crawler in ipairs(crawlers) do
        if string.find(string.lower(ua), crawler, 1, true) then
            return true
        end
    end

    return false
end

-- 函数用于解析操作系统
local function detect_os(ua)
    local os_patterns = {
        ["Windows NT 10.0"] = "Windows 10",
        ["Windows NT 6.3"] = "Windows 8.1",
        ["Windows NT 6.2"] = "Windows 8",
        ["Windows NT 6.1"] = "Windows 7",
        ["Windows NT 6.0"] = "Windows Vista",
        ["Windows NT 5.2"] = "Windows Server 2003/XP x64 Edition",
        ["Windows NT 5.1"] = "Windows XP",
        ["Windows NT 5.0"] = "Windows 2000",
        ["Windows Phone"] = "Windows Phone",
        ["iPhone"] = "iOS",
        ["iPad"] = "iOS",
        ["Macintosh"] = "Mac OS X",
        ["Android"] = "Android",
        ["Linux"] = "Linux",
        ["BlackBerry"] = "BlackBerry",
        ["FreeBSD"] = "FreeBSD",
        ["OpenBSD"] = "OpenBSD",
        ["NetBSD"] = "NetBSD",
        ["SunOS"] = "Solaris",
    }

    for pattern, os_name in pairs(os_patterns) do
        if string.find(ua, pattern, 1, true) then
            return os_name
        end
    end

    return "Unknown"
end

function _M:addReqCount(ip)
    self:Incr(self.REQ_COUNT)
    -- 进行UA分析
    local ua = ngx.var.http_user_agent
    local key = "os_unknown"
    if ua then
        if is_crawler(ua) then
            key = "os_crawler"
        else 
            key = "os_" .. detect_os(ua)
        end
    end
    self:Incr(key)
    -- 进行访问域名分析
    local host = ngx.var.host
    self:Incr("host_" .. host)

    -- 进行来源分析
    local referer = ngx.var.http_referer
    if referer then
        self:Incr("referer_" .. referer)
    end

    -- 进行IP来源分析
    self:Incr("ip_" .. ip)
end

function _M:addStatusCount()
    -- 分析响应码
    local status = ngx.status
    local key = "status_" .. status
    self:Incr(key)
end

function _M:addReqDenyCount()
    self:Incr(self.REQ_DENY_COUNT)
end


function _M:save2Disk(lastDay, hour)
    local keysData = {}
    self.cache:getAllPrefixKeys(self.KEY_PREFIX, function(key)
        local val = tonumber(self.cache:cacheGet(key, 0) or 0)
        self.cache:cacheDel(key)
        keysData[key] = val
    end)
    
    -- 每个小时的数据保存为JSON格式,存储为 count/20210101/01.json 的形式
    local path = "count/" .. lastDay
    local fileName = hour .. ".json"
    local localFile = require "localFile"
    local json = require "cjson"
    localFile.writeFile(path, fileName, json.encode(keysData))
end


function _M:onExitNginx()
    if WAF_CONFIG["statistics"] == "off" then
        return
    end
    local current_time = os.date("*t", ngx.time())
    local hour = current_time.hour
    -- 如果时间不一致
    local lastDayHour = self.cache:cacheGet(self.LAST_DAY_HOUR, 0) or hour
    local lastDay = self.cache:cacheGet(self.LAST_DAY, 0) or ngx.today() 
   
    self:save2Disk(lastDay, hour)
end

function _M:Incr(key)
    -- 未开启统计
    if WAF_CONFIG["statistics"] == "off" then
        return
    end

    local current_time = os.date("*t", ngx.time())
    local hour = current_time.hour

    -- 如果时间不一致
    local lastDayHour = self.cache:cacheGet(self.LAST_DAY_HOUR, 0)
    local lastDay = self.cache:cacheGet(self.LAST_DAY, 0)
    local nowDay = ngx.today() 
    local nowDayHour = hour

    -- 加锁，确保只有一个请求在执行以下操作
    if self.lock:cacheGet(self.LOCK_KEY) then
        return
    end

    self.lock:cacheSet(self.LOCK_KEY, true)

    -- 执行更新操作
    if lastDayHour ~= nowDayHour and lastDay ~= nowDay then
        -- 时间不一样了，将当前时间段的数据缓存到文件中
        self.cache:cacheSet(self.LAST_DAY_HOUR, nowDayHour)
        self.cache:cacheSet(self.LAST_DAY, nowDay)
        if lastDayHour ~= nil then
            -- 获取所有指定前缀的key
            self:save2Disk(lastDay, hour)
        end
    end

   self.lock:cacheDel(self.LOCK_KEY)
    -- 执行缓存增加操作
    self.cache:cacheIncr(self.KEY_PREFIX .. key, 1)
end

return _M
