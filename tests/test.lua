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
client:set_header("User-Agent", "TEST_CLIENT/1.0")
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


function assertContain(a, b, name)
    if string.find(a, b) then
        printColor( color.green,name ..  " Test Passed ")
        return true
    else
        print(color.red .. name.." Test Failed "..color.reset .. " Expected: " ..color.cyan.. b ..color.reset.. " Actual: " .. color.cyan ..a..color.reset)
        return false
    end
end


function assertAll(actual_body, expected_body, actual_status, expected_status, name)
    TOTAL = TOTAL + 1
    if assertContain(actual_body, expected_body, name .. " Body") then
        PASS = PASS + 1
    end
end

TEST_CASE = ""
TOTAL = 0
PASS = 0
function testAll()
    local testCases = {
        cmd = "Command Execution",
    }
    for name, desc in pairs(testCases) do
        TOTAL = 0
        PASS = 0
        TEST_CASE = desc.." - "
        printColor(color.blue, "--------------------------\nTesting "..desc.." Started")
        require(name)
        printColor(color.blue, "Testing "..desc.." Finished")
        printColor(color.green, "Total Test Cases: "..TOTAL)
        printColor(color.green, "Total Passed: "..PASS)
        printColor(color.red, "Total Failed: "..TOTAL - PASS)
        printColor(color.blue, "--------------------------")
    end
end
testAll()