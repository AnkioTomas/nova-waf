-- 初始化
function get_script_directory()
    local script_path = debug.getinfo(1, "S").source:sub(2)
    local script_dir = script_path:match("(.*" .. package.config:sub(1,1) .. ")")
    return script_dir
end

-- 获取当前路径
CURRENT_PATH =  get_script_directory()

-- 全局变量
RULE_FILES = {}
WAF_CONFIG = {}
WHITE_IPS = {}
BLACK_IPS = {}
LOGGERS = {}

-- 更新 package.path 以包含 utils 目录
package.path = package.path .. ";" .. CURRENT_PATH .. "/utils/?.lua"

-- 加载配置文件
function load_config()
    local filename = CURRENT_PATH .. "conf.d/waf.conf"
    WAF_CONFIG = {}
    for line in io.lines(filename) do
       -- ngx.log(ngx.INFO, "WAF Config line: ", line)
        line = string.match(line, "^[^#]*")
        if line then
            line = string.gsub(line, "%s+", "")
            if line ~= "" then
                local key, value = string.match(line, "([^=]+)=([^=]+)")
                if key and value then
                    
                    -- trim
                    key = string.gsub(key, "^%s*(.-)%s*$", "%1")
                    value = string.gsub(value, "^%s*(.-)%s*$", "%1")
                    -- 剔除引号
                    value = string.gsub(value, "^\"(.-)\"$", "%1")
                    WAF_CONFIG[key] = value
                    ngx.log(ngx.INFO, "WAF Config line match: " .. key .. " = " .. value)
                else
                    ngx.log(ngx.WARN, "Invalid config line: " .. line)
                end
            end
        end
    end
end

-- 加载 IP 列表
function load_ips()
    if WAF_CONFIG["mode"] == "off" then
        ngx.log(ngx.INFO, "WAF is off")
        return
    end

    local white_ip_file = CURRENT_PATH .. "conf.d/whiteIp"
    local black_ip_file = CURRENT_PATH .. "conf.d/blackIp"

    WHITE_IPS = {}
    BLACK_IPS = {}

    for line in io.lines(white_ip_file) do
        if line:find("/") then
            local ips = parse_cidr(line)
            for _, ip in ipairs(ips) do
                table.insert(WHITE_IPS, ip)
            end
        else
            table.insert(WHITE_IPS, line)
        end
    end

    for line in io.lines(black_ip_file) do
        if line:find("/") then
            local ips = parse_cidr(line)
            for _, ip in ipairs(ips) do
                table.insert(BLACK_IPS, ip)
            end
        else
            table.insert(BLACK_IPS, line)
        end
    end
end
-- 函数：遍历目录
local function iterate_directory(directory)
    local iter = io.popen('ls "' .. directory .. '"')
    return function()
        local file = iter:read()
        if file and file ~= "." and file ~= ".." then
            return file
        end
    end
end
-- 加载规则
function load_rules()
    if WAF_CONFIG["mode"] == "off" then
        return
    end

    local rules_directory = CURRENT_PATH .. "rules/"
   
    local yml = require "yml"

    for file in iterate_directory(rules_directory) do
        if file:match("%.yml$") then
            local config_key_2 = "exp_" .. file:match("^(%w+)%..*$")  -- 例如 "exp_backup"
            if WAF_CONFIG[config_key_2] == "off" then
                -- 跳过处理此文件
            else
                local file_path = rules_directory .. file
                local file = yml.read_file(file_path)
                local data = yml.parse_yaml(file)
                ngx.log(ngx.INFO, "WAF initialized with rule: ", file_path)
                RULE_FILES[file] = data
            end
        end
    end
end



ngx.log(ngx.INFO, "WAF init...... ")
ngx.log(ngx.INFO, "WAF loading config......")
-- 执行初始化函数
load_config()
ngx.log(ngx.INFO, "WAF loading ips......")
load_ips()
ngx.log(ngx.INFO, "WAF loading rules......")
load_rules()
ngx.log(ngx.INFO, "WAF init finished.")


