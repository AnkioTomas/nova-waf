ngx.log(ngx.INFO, "Nginx Worker is shutting down. Performing cleanup tasks.")

local localCount = require "count"
local localCache = require "cache"
local lock = localCache:new("dict_locks")
local LOCK_KEY = "nginx_exit_lock"
if lock:cacheGet(LOCK_KEY) then
    return
end
lock:cacheSet(LOCK_KEY, true)
localCount:new():onExitNginx()
lock:cacheDel(LOCK_KEY)