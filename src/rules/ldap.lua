local _M = {
    name = "Ldap Injection",
    desc = "检测是否存在可能绕过LDAP安全控制的字符串形式。",
    level = "high",
    position = "all",
    rules = {
        {
            pattern = [[\${jndi:(?:ldap|ldaps|rmi|dns|nis|nds|corba|iiop):]],
            name = "Basic and Protocol Variants JNDI Injection",
            confidence = 3
        },
        {
            pattern = [[\%24\%7Bjndi:(?:ldap|ldaps|rmi|dns|nis|nds|corba|iiop):]],
            name = "URL Encoded JNDI Injection",
            confidence = 3
        },
        {
            pattern = [[\${(.+)?j}\${(.+)?n}\${(.+)?d}\${(.+)?i}:]],
            name = "Colon Prefixed Lowercase Function Injection",
            confidence = 3
        },

    }
}

return _M
