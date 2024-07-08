local _M = {
  name = "XXE",
  desc = "检测是否存在通过XML实体加载外部资源的漏洞。",
  level = "high",
  position = "all",
  rules = {
    {
      pattern = [[ <!ENTITY\s+.+> ]],
      name = "Generic ENTITY Declaration",
      confidence = 9
    },
    {
      pattern = [[ <!DOCTYPE\s+.+\[ ]],
      name = "DOCTYPE Declaration",
      confidence = 2
    },
    {
      pattern = [[ <!ENTITY\s+.+\s+SYSTEM\s+['\"].+['\"]\s*> ]],
      name = "SYSTEM Entity Declaration",
      confidence = 9
    },
    {
      pattern = [[ <!ENTITY\s+.+\s+PUBLIC\s+['\"].+['\"]\s+['\"].+['\"]\s*> ]],
      name = "PUBLIC Entity Declaration",
      confidence = 9
    }
  }
}

return _M
