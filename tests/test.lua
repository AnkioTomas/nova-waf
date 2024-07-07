-- 初始化
function get_script_directory()
    local script_path = debug.getinfo(1, "S").source:sub(2)
    local script_dir = script_path:match("(.*" .. package.config:sub(1,1) .. ")")
    return script_dir
end

-- 获取当前路径
CURRENT_PATH =  get_script_directory()

package.path = package.path .. ";" .. CURRENT_PATH .. "/?.lua"

-- 构建http请求
HttpClient = require "HttpClient"

client = HttpClient:new()

url = "http://localhost"

color = {
    reset = "\27[0m",  -- 重置颜色
    black = "\27[30m", -- 黑色
    red = "\27[31m",   -- 红色
    green = "\27[32m", -- 绿色
    yellow = "\27[33m",-- 黄色
    blue = "\27[34m",  -- 蓝色
    magenta = "\27[35m",-- 洋红色
    cyan = "\27[36m",  -- 青色
    white = "\27[37m", -- 白色
}


function printColor(color1, msg)
    print(color1 .. msg .. color.reset)
end

function assertEqual(a, b,name)

    if a == b then
        printColor(color.green,name.. " 测试通过")
    else
        printColor(color.red, name.."测试失败".." 期望值:"..b.." 实际值:"..a)
    end
end

function assertContain(a, b,name)
    if string.find(a,b) then
        printColor(color.green,name.. " 测试通过")
    else
        printColor(color.red, name.."测试失败".." 期望值:"..b.." 实际值:"..a)
    end
end


printColor(color.blue , "测试 命令执行" )

require "cmd"


printColor(color.blue , "测试 命令执行结束" )