local _M = {
  name = "Sql Injection",
  desc = "SQL注入是一种常见的攻击手段，通过在输入框中输入SQL语句，获取数据库中的数据。",
  level = "high",
  position = "uri,body",
  rules = {
    {
      pattern = [[ select\s+.*\s+from\s+.* ]],
      name = "Select-From Statement",
      confidence = 3
    },
    {
      pattern = [[ select\s+.*\s+limit\s+.* ]],
      name = "Select-Limit Statement",
      confidence = 3
    },
    {
      pattern = [[ UNION\s+SELECT ]],
      name = "Union-Select Statement",
      confidence = 3
    },
    {
      pattern = [[ sleep\s*\(\s*\d+\s*\) ]],
      name = "Sleep Function",
      confidence = 3
    },
    {
      pattern = [[ benchmark\s*\(\s*\d+\s*,\s*.*\s*\) ]],
      name = "Benchmark Function",
      confidence = 3
    },
    {
      pattern = [[ FROM\s+information_schema ]],
      name = "Information Schema Access",
      confidence = 3
    },
    {
      pattern = [[ INTO\s+(?:dump|out)file\s+.* ]],
      name = "Into Outfile Statement",
      confidence = 3
    },
    {
      pattern = [[ GROUP\s+BY]],
      name = "Group By Statement",
      confidence = 3
    },
    {
      pattern = [[ load_file\s*\(\s*.*\s*\) ]],
      name = "Load File Function",
      confidence = 3
    },
    {
      pattern = [[ (?:\sor\s|\sand\s).*=.* ]],
      name = "Boolean Logic SQL Injection",
      confidence = 2
    },
    {
      pattern = [[ (?:\sunion\s|\sselect\s|\sinsert\s|\supdate\s|\sdelete\s|\sdrop\s|\salter\s) ]],
      name = "SQL Keywords",
      confidence = 2
    },

  }
}

return _M
