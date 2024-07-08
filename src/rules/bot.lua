local _M = {
    name = "Bot",
    desc = "恶意爬虫是一种恶意程序，通过模拟浏览器行为，对网站进行大量访问，占用服务器资源。",
    level = "low",
    location = "ua",
    rules = {
        {
            pattern = [[ user-agent: (go|curl|wget|python-requests|libwww-perl|httpclient|python-urllib|http_request|java|scrapy|php|node\\.js|mechanize|axios|httpie|okhttp|lua-resty-http|Go-http-client|Jakarta Commons-HttpClient|Apache-HttpClient|Jakarta HttpClient|libcurl|python-httpx|python-tornado|guzzlehttp|httplib2|perseus|resty|simplepie|typhoeus|axios/axios|aiohttp|http\\.client|http\\.request|http\\.rb|Net::HTTP|HTTPie|PycURL|Requests|httplib|Mechanize|Scrapy|LWP::Simple|RestClient|async-http-client) ]],
            name = "Common Malicious Crawler User-Agent Strings",
            confidence = 9
        }
    }
}

return _M
