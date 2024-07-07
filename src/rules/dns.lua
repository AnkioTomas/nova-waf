local _M = {
    name = "DNSLog黑名单",
    desc = "检测是否存在通过DNSLog加载外部资源的漏洞。",
    level = "medium",
    location = "all",
    rules = {
        -- 检测DNSLog黑名单域名
        "dnslog%.[%w]+",
        "dig%.pm",
        "ceye%.[%w]+",
        "eyes%.sh"
    }
}

return _M
