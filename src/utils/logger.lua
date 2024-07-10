local concat = table.concat
local newtab = table.new
local timerat = ngx.timer.at

local _M = {}
local mt = {__index = _M}
local localFile = require "localFile"
local cache = require "cache"
-- 创建新的日志对象
function _M:new(host)
    local t = {
        flush_limit = 4096, -- 4KB的刷新限制
        flush_timeout = 1,  -- 1秒的刷新超时

        buffered_size = 0,  -- 当前缓冲区大小
        buffer_index = 0,   -- 缓冲区索引
        buffer_data = newtab(20000, 0), -- 初始化一个新的表来存储缓冲数据

        host = host,                 -- 主机名
        timer = false,                -- 定时器
        LOCK_KEY = "logger_lock_" .. host, -- 锁的key
        lock = cache:new("dict_locks")
    }

    setmetatable(t, mt)
    return t
end

-- 将缓冲区数据写入文件
local function writeFile(self, value)

    local day = ngx.today()
    local logPath = "logs/"..day
    local filename = self.host..".log"

    localFile.writeFile(logPath, filename, value)

end


-- 刷新缓冲区，将缓冲区数据写入文件
local function flushBuffer(self)
    if self.buffered_size == 0 then
        return
    end

      -- 加锁，确保只有一个请求在执行以下操作
      
  
    
    if self.lock:cacheGet(self.LOCK_KEY) then
        return
    end  
     
    self.lock:cacheSet(self.LOCK_KEY, true)

    local buffer = concat(self.buffer_data, "", 1, self.buffer_index)
    writeFile(self, buffer)

    self.buffered_size = 0
    self.buffer_index = 0
    self.buffer_data = newtab(20000, 0)

    -- 解锁
    self.lock:cacheDel(self.LOCK_KEY)
    
end

-- 定时器回调函数，用于定期刷新缓冲区
local function flushPeriod(premature, self)
    flushBuffer(self)
    self.timer = false
end

-- 将消息写入缓冲区
local function writeBuffer(self, msg, msg_len)
    self.buffer_index = self.buffer_index + 1
    self.buffer_data[self.buffer_index] = msg
    self.buffered_size = self.buffered_size + msg_len
end

-- 启动定时器
local function startTimer(self)
    if not self.timer then
        local ok, err = timerat(self.flush_timeout, flushPeriod, self)
        if not ok then
            ngx.log(ngx.ERR, "failed to create the timer: ", err)
            return
        end
        self.timer = true
    end
end

-- 记录日志
function _M:log(msg)
    msg = tostring(msg)
    local msg_len = #msg
    local len = msg_len + self.buffered_size

    writeBuffer(self, msg, msg_len)

    if len >= self.flush_limit then
        flushBuffer(self)
    else
        startTimer(self)
    end
end



return _M
