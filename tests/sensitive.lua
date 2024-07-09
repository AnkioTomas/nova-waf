local subname = ""
-- 发送 GET 请求
local response = nil

local test_cases = {
    -- Configuration File Exposure
    "/config.xml",
    "/settings.json",
    "/var/www/database.ini",
    "/env.cfg",
    "folder/plist.properties",
    
    -- Key or Certificate File Exposure
    "/key.pem",
    "/cert.pub",
    "/var/ssl/id_rsa.key",
    "/id_dsa.pem",
    "folder/rsa.pub",
    
    -- Password or Credentials File Exposure
    "/password.txt",
    "/credentials.csv",
    "/var/www/secret.log",
    "/token.json",
    "folder/passwd.yaml",
    
    -- Backup or Log File Exposure
    "/backup.log",
    "/old.dat",
    "/var/www/backup.bak",
    "/log.db",
    "folder/backup.csv",
    

  }
  


for _, path in ipairs(test_cases) do
    subname = "PATH TEST - "..path
    response = client:get(url .."/"..path)

    assertAll(response.body, "Attack detected", response.status, "403 Forbidden", TEST_CASE..subname)
end