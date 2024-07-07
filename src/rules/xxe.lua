local _M = {
  name = "XXE",
  desc = "检测是否存在通过XML实体加载外部资源的漏洞。",
  level = "high",
  position = "all",
  rules = {
      "<!ENTITY%s+.+>",
      "<!DOCTYPE%s+.+%[",
      "<!ENTITY%s+.+%s+SYSTEM%s+['\"].+['\"]%s*>",
      "<!ENTITY%s+.+%s+PUBLIC%s+['\"].+['\"]%s+['\"].+['\"]%s*>"
  }
}

return _M
