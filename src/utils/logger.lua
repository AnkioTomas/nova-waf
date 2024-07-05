local concat = table.concat
local newtab = table.new
local timerat = ngx.timer.at
local setmetatable = setmetatable

local _M = {}

local mt = {__index = _M}

-- 创建新的日志对象
function _M:new(logPath, host, rolling)
    local t = {
        flush_limit = 4096, -- 4KB的刷新限制
        flush_timeout = 1,  -- 1秒的刷新超时

        buffered_size = 0,  -- 当前缓冲区大小
        buffer_index = 0,   -- 缓冲区索引
        buffer_data = newtab(20000, 0), -- 初始化一个新的表来存储缓冲数据

        logPath = logPath,           -- 日志路径
        prefix = logPath .. host .. '_', -- 日志文件前缀
        rolling = rolling or false,  -- 是否启用滚动日志
        host = host,                 -- 主机名
        timer = nil                  -- 定时器
    }

    setmetatable(t, mt)
    return t
end

-- 检查是否需要刷新缓冲区
local function needFlush(self)
    if self.buffered_size > 0 then
        return true
    end
    return false
end

-- 加锁，防止并发刷新缓冲区
local function flushLock(self)
    local dic_lock = ngx.shared.dict_locks
    local locked = dic_lock:get(self.host)
    if not locked then
        local succ, err = dic_lock:set(self.host, true)
        if not succ then
            ngx.log(ngx.ERR, "failed to lock logfile " .. self.host .. ": ", err)
        end
        return succ
    end
    return false
end

-- 解锁
local function flushUnlock(self)
    local dic_lock = ngx.shared.dict_locks
    local succ, err = dic_lock:set(self.host, false)
    if not succ then
        ngx.log(ngx.ERR, "failed to unlock logfile " .. self.host .. ": ", err)
    end
    return succ
end

-- 将缓冲区数据写入文件
local function writeFile(self, value)
    local fileName = ''
    if self.rolling then
        fileName = self.prefix .. ngx.today() .. ".log"
    else
        fileName = self.logPath
    end

    local file = io.open(fileName, "a+")

    if file == nil or value == nil then
        return
    end

    file:write(value)
    file:flush()
    file:close()

    return
end

-- 刷新缓冲区，将缓冲区数据写入文件
local function flushBuffer(self)
    if not needFlush(self) then
        return true
    end

    if not flushLock(self) then
        return true
    end

    local buffer = concat(self.buffer_data, "", 1, self.buffer_index)
    writeFile(self, buffer)

    self.buffered_size = 0
    self.buffer_index = 0
    self.buffer_data = newtab(20000, 0)

    flushUnlock(self)
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
    return self.buffered_size
end

-- 启动定时器
local function startTimer(self)
    if not self.timer then
        local ok, err = timerat(self.flush_timeout, flushPeriod, self)
        if not ok then
            ngx.log(ngx.ERR, "failed to create the timer: ", err)
            return
        end
        if ok then
            self.timer = true
        end
    end
    return self.timer
end

-- 记录日志
function _M:log(msg)
    if type(msg) ~= "string" then
        msg = tostring(msg)
    end

    local msg_len = #msg
    local len = msg_len + self.buffered_size

    if len < self.flush_limit then
        writeBuffer(self, msg, msg_len)
        startTimer(self)
    elseif len >= self.flush_limit then
        writeBuffer(self, msg, msg_len)
        flushBuffer(self)
    end
end

return _M
