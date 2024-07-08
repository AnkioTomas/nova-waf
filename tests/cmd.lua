
-- 设置自定义头部

local subname = "Noromal GET Request 1"
-- 发送 GET 请求
local response = client:get(url)
assertAll(response.body, "hello, world", response.status, "200 OK", TEST_CASE..subname)

local normal_requests = {
    -- 常见正常请求
    "cmd=hello",
    "username=johndoe",
    "action=view&item=123",
    "search=lua+patterns",
    "order=id&sort=asc",
    "category=books&author=John+Doe",
    "page=contact",
    "submit=true",
    "feedback=I+love+your+site!",
    "product_id=456&quantity=2",
    "article_id=789&comment_id=123",
    "session_id=abcdef123456",
    "color=blue&size=medium",
    "token=xyz789",
    "referrer=https://example.com",
    "mode=edit&post_id=101",
    "newsletter_signup=true",
    "email=johndoe@example.com",
    "download=file.zip",
    "preview=true",
    "callback=handleResponse",
    "debug=off",
    "format=json",
    "theme=dark",
    "lang=en",
    "timezone=UTC",
    "currency=USD",
    "filter=date&range=last30days"
}

-- 发送 GET 请求
for key, normal_request in ipairs(normal_requests) do
    subname = "Normal GET Request - "..normal_request
    response = client:get(url.."/1.php",normal_request)
    assertAll(response.body, "hello, world", response.status, "200 OK", TEST_CASE..subname)
end



-- GET 2=id

assertAll(response.body, "hello, world", response.status, "200 OK", TEST_CASE..subname)

local test_cases = {
    -- PHP Functions
    "exec('ls')",
    "system('whoami')",
    "passthru('id')",
    "shell_exec('cat /etc/passwd')",
    "proc_open('ps', array(), $pipes)",
    "popen('ls', 'r')",

    -- Python Functions
    "os.system('uname -a')",
    "os.popen('ifconfig').read()",
    "subprocess.Popen(['ls'], stdout=subprocess.PIPE)",
    "subprocess.call(['ps'])",
    "subprocess.run(['netstat'])",
    "eval('2 + 2')",
    "exec('print(\"Hello, World!\")')",

    -- Ruby Methods
    "`system('ls')`",
    "`exec('cat /etc/shadow')`",
    "`popen('whoami')`",
    "`spawn('id')`",
    "`IO.popen('ps')`",
    "`IO.sysopen('/etc/hosts')`",
    "`eval('1 + 1')`",

    -- Perl Functions
    "`system('ls')`",
    "`exec('cat /etc/passwd')`",
    "`open('file.txt', 'w')`",
    "`eval('1 + 1')`",

    -- Java Methods
    "Runtime.getRuntime().exec('ls')",
    "Runtime.getRuntime().exec('whoami')",
    "ProcessBuilder('id').start()",

    -- General Eval Functions
    "eval('ls')",
    "eval('whoami')",

    -- Non-alphanumeric Characters Around Command Execution Functions
    ";exec('ls');",
    "&&system('whoami')&&",
    "`popen('id')`",
    "$(`subprocess.Popen(['ps'])`)",

    -- Logical Operators and Newline Characters
    "ls||cat /etc/passwd",
    "whoami&&id",
    "uname -a\nid",
    "ps\rnetstat",

    -- Command Substitution and Variable Interpolation
   -- "${ls}",
    "$(`whoami`)",
   -- "`id`",
    "\\u0024{uname -a}",
    --"\\u0024(`ps`)",

    -- Common Linux Commands and Files
   -- "ls",
    "cat /etc/passwd",
    "whoami",
    "uname -a",
   -- "id",
  --  "ps",
    "netstat",
    "ifconfig",
    "wget http://example.com",
    "curl http://example.com",
    "chmod 777 /tmp",
    "chown root:root /etc/passwd",
    "find / -name 'passwd'",
    "grep 'root' /etc/passwd",
    "echo 'Hello, World!'",
    "kill -9 1234",
    "cat /etc/shadow",
    "cat /etc/hosts",
  --  "ls /var/log/",
    "touch /tmp/testfile",
   -- "ls /home/",

    -- Common Windows Commands and Files
    "dir",
    "type C:\\Windows\\System32\\drivers\\etc\\hosts",
    "whoami",
    "systeminfo",
    "tasklist",
    "netstat",
    "ipconfig",
    "certutil -urlcache -split -f http://example.com file.txt",
    "powershell Get-Process",
    "echo Hello, World!",
    "findstr /i 'error' logfile.txt",
    "ping example.com",
    "type C:\\Windows\\System32\\config\\SAM",
    "dir C:\\Users\\",
    "dir C:\\Program Files\\",
    "type C:\\Temp\\testfile.txt"
}

-- 发送 GET 请求
for key, test_case in ipairs(test_cases) do
    subname = "GET Request with Command Execution - "..test_case
    response = client:get(url.."/1.php","2="..test_case)
    assertAll(response.body, "Command Injection", response.status, "403 Forbidden", TEST_CASE..subname)
end