local _M = {
    name = "DNSLog",
    desc = "检测是否存在通过DNSLog加载外部资源的漏洞。",
    level = "medium",
    position = "all",
    rules = {
        {
            pattern = [[ dnslog\.[\w]+ ]],
            name = "DNSLog Blacklist Domain",
            confidence = 3
        },
        {
            pattern = [[ dig\.pm ]],
            name = "Dig.pm Domain",
            confidence = 3
        },
        {
            pattern = [[ ceye\.[\w]+ ]],
            name = "Ceye Domain",
            confidence = 3
        },
        {
            pattern = [[ "eyes\.sh ]],
            name = "Eyes.sh Domain",
            confidence = 3
        }
    }
}

return _M
