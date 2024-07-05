local tonumber = tonumber
local tostring = tostring
local ipairs = ipairs
local ngxmatch = ngx.re.match

local _M = {}

-- 缓存键前缀
-- local WAF_KEY = "nava-waf"

-- 使用 ngx.shared.DICT 作为共享缓存
local cache = ngx.shared.nova_waf

-- 将数据存储在共享缓存中
function _M.cacheSet(key, value, expireTime)
    -- 设置键值对，并指定过期时间（可选）
    -- 返回值：成功返回 true，失败返回 nil，并记录错误日志
    local ok, err = cache:set(key, value, expireTime)
    if not ok then
        ngx.log(ngx.ERR, "failed to set key: " .. key .. " ", err)
    end
    return ok, err
end

-- 批量设置键值对
function _M.cacheBatchSet(keyTable, value, keyPrefix)
    local ok, err = true, nil
    if keyPrefix then
        -- 使用指定前缀设置多个键值对
        for _, ip in ipairs(keyTable) do
            ok, err = cache:set(keyPrefix .. ip, value)
            if not ok then
                ngx.log(ngx.ERR, "failed to set key: " .. keyPrefix .. ip .. " ", err)
                break
            end
        end
    else
        -- 直接设置多个键值对
        for _, ip in ipairs(keyTable) do
            ok, err = cache:set(ip, value)
            if not ok then
                ngx.log(ngx.ERR, "failed to set key: " .. ip .. " ", err)
                break
            end
        end
    end
    return ok, err
end

-- 获取指定键的值
function _M.cacheGet(key)
    -- 获取指定键的值
    -- 返回值：成功返回值，失败返回 nil，并记录错误日志
    local value, err = cache:get(key)
    if not value then
        ngx.log(ngx.WARN, "failed to get key: " .. key.. " ", err)
    end
    return value, err
end

-- 自增指定键的值
function _M.cacheIncr(key, expireTime)
    -- 自增指定键的值，如果键不存在则初始化为 1
    -- 返回值：成功返回新的值，失败返回 nil，并记录错误日志
    local value, err = cache:incr(key, 1)
    if not value then
        -- 如果键不存在，则初始化为 1，并设置过期时间（可选）
        value, err = cache:add(key, 1, expireTime)
        if not value then
            ngx.log(ngx.ERR, "failed to incr key: " .. key, err)
        end
    elseif value == 1 and expireTime and expireTime > 0 then
        -- 如果自增后的值为 1，并且设置了过期时间，则设置过期时间
        cache:expire(key, expireTime)
    end
    return value, err
end

-- 删除指定键值对
function _M.cacheDel(key)
    -- 删除指定键值对
    -- 返回值：成功返回 true，失败返回 nil，并记录错误日志
    local ok, err = cache:delete(key)
    if not ok then
        ngx.log(ngx.ERR, "failed to delete key: " .. key, err)
    end
    return ok, err
end

return _M
