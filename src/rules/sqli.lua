local _M = {
  name = "SQL注入",
  desc = "SQL注入是一种常见的攻击手段，通过在输入框中输入SQL语句，获取数据库中的数据。",
  level = "high",
  position = "all",
  rules = {
      "select%s+.*%s+from%s+.*",         -- 检测SELECT-FROM语句
      "select%s+.*%s+limit%s+.*",        -- 检测SELECT-LIMIT语句
      "(?i:union%s+select)",             -- 不区分大小写检测UNION SELECT
      "sleep%s*%(%s*%d+%s*%)",           -- 检测SLEEP函数
      "benchmark%s*%(%s*%d+%s*,%s*.*%s*%)",  -- 检测BENCHMARK函数
      "(?i:from%s+information_schema)",  -- 不区分大小写检测访问INFORMATION_SCHEMA
      "into%s+(?:dump|out)file%s+.*",    -- 检测INTO OUTFILE和INTO DUMPFILE
      "group%s+by%s+.*%s*%(",            -- 检测GROUP BY语句
      "load_file%s*%(%s*.*%s*%)",        -- 检测LOAD_FILE函数
      "(?:'|\"|`|;|--|#)",               -- 检测SQL中的注释和字符串终止符
      "(?:or|and)%s+.*=.*",              -- 检测布尔逻辑SQL注入
      "(?:union|select|insert|update|delete|drop|alter)%s+"  -- 检测SQL关键字
  }
}

return _M