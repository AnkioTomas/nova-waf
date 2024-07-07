local _M = {
    name = "命令执行",
    desc = "检测到可能的命令执行行为",
    level = "high",
    position = "all",
    rules = {
    -- PHP functions
    "(exec|system|passthru|shell_exec|proc_open|popen)%s*%b()",
    -- Python functions
    "(os%.system|os%.popen|subprocess%.Popen|subprocess%.call|subprocess%.run|eval|exec)%s*%b()",
    -- Ruby methods
    "`(system|exec|popen|spawn|IO%.popen|IO%.sysopen|eval)%s*%b()",
    -- Perl functions
    "`(system|exec|open|eval)%s*%b()",
    -- Java methods
    "(Runtime%.getRuntime%b()%..*%b()|ProcessBuilder%b())",
    -- General eval functions
    "eval%s*%b()",
    -- General backtick commands
    "`[^`]+`",
    -- Detect common command injection symbols
    "[|`$&;><]",
    -- Match non-alphanumeric characters around command execution functions
    "[^a-zA-Z0-9](exec|system|passthru|shell_exec|proc_open|popen|os%.system|os%.popen|subprocess%.Popen|subprocess%.call|subprocess%.run|eval|exec|Runtime%.getRuntime%b()%..*%b()|ProcessBuilder%b()|`[^`]+`)[^a-zA-Z0-9]",
    -- Detect logical operators and newline characters
    "([|][|]|[&][&]|\\n|\\r)",
    -- Detect command substitution and variable interpolation
    "(%${.*}|%$%b()|%$%$|`.*`|\\u0024%{.*}|\\u0024%b())"
    }
}

return _M
