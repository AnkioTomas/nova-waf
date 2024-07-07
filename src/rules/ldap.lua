local _M = {
    name = "LDAP安全检测绕过",
    desc = "检测是否存在可能绕过LDAP安全控制的字符串形式。",
    level = "high",
    location = "all",
    rules = {
        -- 检测可能绕过LDAP安全控制的字符串形式
        "%${jndi:",
        "%$%%7Bjndi:",
        "%%24%%7Bjndi:",
        "%${jNdI:ldAp",
        "%${jndi:%${lower:l}%${lower:d}%${lower:a}%${lower:p}:",
        "%${%${lower:j}%${lower:n}%${lower:d}i:",
        "%${%${::%-j}%${::%-n}%${::%-d}%${::%-i}:%${::%-l}%${::%-d}%${::%-a}%${::%-p}:",
        "%${%${env:BARFOO:%-j}ndi%${env:BARFOO:%-:}%${env:BARFOO:%-l}dap%${env:BARFOO:%-:}"
    }
}

return _M
