
local name = "命令执行 - "
-- 设置自定义头部
client:set_header("User-Agent", "MyLuaClient/1.0")
local subname = "正常请求"
-- 发送 GET 请求
local response = client:get(url)

assertContain(response.body, "hello, world", name..subname)
assertContain(response.status, "200 OK",  name..subname)

-- 命令执行
subname = "GET 命令执行 1"
response = client:get(url.."/shell.php?cmd=whoami")

assertContain(response.body, "hello, world", name..subname)
assertContain(response.status, "200 OK",  name..subname)


