
local _M = {}


function _M.ensureDirExists(path)
    local ok, err = os.execute("mkdir -p " .. path)
    if not ok then
        ngx.log(ngx.ERR, "Failed to create directory: ", path, " - ", err)
        return false
    end
    return true
end

function _M.writeFile(path,filename, value)
    local log_path = WAF_CONFIG["log_path"].."/"..path
    
    -- 确保目录存在
    _M.ensureDirExists(log_path)
    
    local file_path = log_path .. "/" .. filename
    local file, err = io.open(file_path, "w")
    if not file then
        ngx.log(ngx.ERR, "Failed to open file for writing: ", file_path, " - ", err)
        return false
    end
    
    file:write(value)
    file:close()
    return true
end


return _M