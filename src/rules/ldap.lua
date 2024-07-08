local _M = {
    name = "Ldap Injection",
    desc = "检测是否存在可能绕过LDAP安全控制的字符串形式。",
    level = "high",
    position = "all",
    rules = {
        {
            pattern = [[ \${jndi: ]],
            name = "Basic JNDI Injection",
            confidence = 3
        },
        {
            pattern = [[ \${jndi:ldap }]],
            name = "URL Encoded JNDI Injection 1",
            confidence = 3
        },
        {
            pattern = [[ \%24\%7Bjndi: ]],
            name = "URL Encoded JNDI Injection 2",
            confidence = 3
        },
        {
            pattern = [[ \${jNdI:ldAp ]],
            name = "Mixed Case JNDI Injection",
            confidence = 3
        },
        {
            pattern = [[ \${jndi:\${lower:l}\${lower:d}\${lower:a}\${lower:p}: ]],
            name = "Lowercase Function Injection",
            confidence = 3
        },
        {
            pattern = [[ \${\${lower:j}\${lower:n}\${lower:d}i: ]],
            name = "Nested Lowercase Function Injection",
            confidence = 3
        },
        {
            pattern = [[ \${\${::%-j}\${::%-n}\${::%-d}\${::%-i}:\${::%-l}\${::%-d}\${::%-a}\${::%-p}: ]],
            name = "Colon Prefixed Lowercase Function Injection",
            confidence = 3
        },
        {
            pattern = [[ \${\${env:BARFOO:%-j}ndi\${env:BARFOO:%-:}\${env:BARFOO:%-l}dap\${env:BARFOO:%-:} ]],
            name = "Environment Variable Injection",
            confidence = 3
        }
    }
}

return _M
