local _M = {
    name = "DNSLog",
    desc = "检测是否存在通过DNSLog加载外部资源的漏洞。",
    level = "medium",
    position = "uri,body",
    rules = {
        {
            pattern = [[ dnslog\.[\w]+ ]],
            name = "DNSLog Blacklist Domain",
            confidence = 2
        },
        {
            pattern = [[ dig\.pm ]],
            name = "Dig.pm Domain",
            confidence = 2
        },
        {
            pattern = [[ ceye\.[\w]+ ]],
            name = "Ceye Domain",
            confidence = 2
        },
        {
            pattern = [[ "eyes\.sh ]],
            name = "Eyes.sh Domain",
            confidence = 2
        }
    }
}

return _M
