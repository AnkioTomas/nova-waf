local _M = {
    name = "DNSLog",
    desc = "检测是否存在通过DNSLog加载外部资源的漏洞。",
    level = "medium",
    location = "all",
    rules = {
        {
            pattern = [[ dnslog\.[\w]+ ]],
            name = "DNSLog Blacklist Domain",
            confidence = 9
        },
        {
            pattern = [[ dig\.pm ]],
            name = "Dig.pm Domain",
            confidence = 9
        },
        {
            pattern = [[ ceye\.[\w]+ ]],
            name = "Ceye Domain",
            confidence = 9
        },
        {
            pattern = [[ "eyes\.sh ]],
            name = "Eyes.sh Domain",
            confidence = 9
        }
    }
}

return _M
