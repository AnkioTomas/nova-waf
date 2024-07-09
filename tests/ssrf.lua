local subname = ""
-- 发送 GET 请求
local response = nil

local test_cases = [[
gopher://example.com
doc://internal.resource
php://localhost
glob://www.example.com
file:///etc/passwd
phar://phar.example.com
zlib://compressed.data
ftp://192.168.1.1
ldap://directory.service
dict://dictionary.reference
ogg://media.file
data://base64data
smb://sharedfolder
tftp://192.168.1.2
rsync://backup.server
telnet://remote.system
jdbc:mysql://database.server
rmi://remote.method.invocation
dns://resolver.query
ws://websocket.service
wss://secure.websocket
sftp://secure.ftp.server
]]
for line in string.gmatch(test_cases, "([^\n]*)\n?") do
    if line ~= "" then
        subname = "SSRF TEST - "..line
    response = client:get(url .."/","link="..line)

    assertAll(response.body, "Attack detected", response.status, "403 Forbidden", TEST_CASE..subname)
    end
end

