local _M = {
    name = "Command Injection",  
    desc = "检测到可能的命令执行行为",  
    level = "high",  
    position = "all",  
    rules = {  
        {
            pattern = [[ (exec|system|passthru|shell_exec|proc_open|popen) ]],
            name = "PHP Functions",
            confidence = 9
        },
        {
            pattern = [[ (os\.system|os\.popen|subprocess\.Popen|subprocess\.call|subprocess\.run|eval|exec) ]],
            name = "Python Functions",
            confidence = 9
        },
        {
            pattern = [[ (system|exec|popen|spawn|IO\.popen|IO\.sysopen|eval) ]],
            name = "Ruby Methods",
            confidence = 9
        },
        {
            pattern = [[ (system|exec|open|eval) ]],
            name = "Perl Functions",
            confidence = 9
        },
        {
            pattern = [[ (Runtime\.getRuntime|ProcessBuilder) ]],
            name = "Java Methods",
            confidence = 9
        },
        {
            pattern = "eval",
            name = "General Eval Functions",
            confidence = 9
        },
        {
            pattern = [[ (exec|system|passthru|shell_exec|proc_open|popen|os\.system|os\.popen|subprocess\.Popen|subprocess\.call|subprocess\.run|eval|exec|Runtime\.getRuntime|ProcessBuilder) ]],
            name = "Non-alphanumeric Characters Around Command Execution Functions",
            confidence = 9
        },
        {
            pattern = [[ ([|][|]|[&][&]|\n|\r) ]],
            name = "Logical Operators and Newline Characters",
            confidence = 5 
        },
        {
            pattern = [[ (cat|whoami|uname|netstat|ifconfig|wget|curl|chmod|chown|find|grep|echo|kill)[\s\"'`}]?(?!\w) ]],
            name = "Common Linux Commands",
            confidence = 5  
        },
        {
            pattern = [[ (/etc/passwd|/etc/shadow|/etc/hosts|/var/log/|/tmp/|/home/) ]],
            name = "Common Linux Files",
            confidence = 5 
        },
        {
            pattern = [[ (C:\\Windows\\System32\\drivers\\etc\\hosts|C:\\Windows\\System32\\config\\|C:\\Users\\|C:\\Program Files\\|C:\\Temp\\) ]],
            name = "Common Windows Files",
            confidence = 5  
        },
        {
            pattern = [[ (dir|type|whoami|systeminfo|tasklist|netstat|ipconfig|certutil|powershell|echo|copy|findstr|ping|tracert|nslookup|net|netsh|wmic)[\s\"'`}]?(?!\w) ]],
            name = "Common Windows Commands and Files",
            confidence = 5  
        }
            
    }
}

return _M
