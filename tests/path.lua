local subname = ""
-- 发送 GET 请求
local response = nil

local test_cases = {
    -- Basic JNDI Lookup
    "../../../../etc/somedata",
    -- Obfuscated JNDI Lookup
    "../..././etc/somedata",
}



for _, path in ipairs(test_cases) do
    subname = "PATH TEST - "..path
    response = client:get(url .."/", "link="..path)

    assertAll(response.body, "Path Overflow", response.status, "403 Forbidden", TEST_CASE..subname)
end