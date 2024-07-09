local subname = ""
-- 发送 GET 请求
local response = nil

local dns = {
   "dnslog.cn",
   "dnslog.com",
    "dnslog.io",
    "dnslog.xyz",
    "ceye.io",
}
for _, test_ua in ipairs(dns) do
    subname = "DNS BlackList - "..test_ua
    response = client:get(url .. "/?link="..test_ua)

    assertAll(response.body, "DNSLog", response.status, "403 Forbidden", TEST_CASE..subname)
end