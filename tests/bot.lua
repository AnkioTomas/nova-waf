local subname = ""
-- 发送 GET 请求
local response = nil
local normalUA = {
    "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)",
    "Mozilla/5.0 (compatible; Bingbot/2.0; +http://www.bing.com/bingbot.htm)",
    "Mozilla/5.0 (compatible; Baiduspider/2.0; +http://www.baidu.com/search/spider.html)",
    "Mozilla/5.0 (compatible; YandexBot/3.0; +http://yandex.com/bots)",
}
for _, test_ua in ipairs(normalUA) do
    subname = "Common User-Agent - "..test_ua
    client:set_header("User-Agent", test_ua)
    response = client:get(url .. "/")
    assertAll(response.body, "hello, world", response.status, "200 OK", TEST_CASE..subname)
end
local maliciousUserAgents = {
    "go",
    "curl",
    "wget",
    "python-requests",
    "libwww-perl",
    "httpclient",
    "python-urllib",
    "http_request",
    "java",
    "scrapy",
    "php",
    "mechanize",
    "axios",
    "httpie",
    "okhttp",
    "lua-resty-http",
    "Go-http-client",
    "Jakarta Commons-HttpClient",
    "Apache-HttpClient",
    "Jakarta HttpClient",
    "libcurl",
    "python-httpx",
    "python-tornado",
    "guzzlehttp",
    "httplib2",
    "perseus",
    "resty",
    "simplepie",
    "typhoeus",
    "axios/axios",
    "aiohttp",
    "Net::HTTP",
    "HTTPie",
    "PycURL",
    "Requests",
    "httplib",
    "Mechanize",
    "Scrapy",
    "LWP::Simple",
    "RestClient",
    "async-http-client"
}
for _, test_ua in ipairs(maliciousUserAgents) do
    subname = "Malicious User-Agent - "..test_ua
    client:set_header("User-Agent", test_ua)
    response = client:get(url .. "/")

    assertAll(response.body, "Attack detected", response.status, "403 Forbidden", TEST_CASE..subname)
end