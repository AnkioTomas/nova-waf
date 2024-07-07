local _M = {
  name = "XSS",
  desc = "XSS是一种常见的攻击手段，通过在输入框中输入JavaScript代码，获取用户的Cookie信息。",
  level = "medium",
  position = "all",
  rules = {
      "<script\\b[^<]*(?:(?!<\\/script>)<[^<]*)*<\\/script>",
      "<iframe\\b[^<]*(?:(?!<\\/iframe>)<[^<]*)*<\\/iframe>",
      "<object\\b[^<]*(?:(?!<\\/object>)<[^<]*)*<\\/object>",
      "<embed\\b[^<]*(?:(?!<\\/embed>)<[^<]*)*<\\/embed>",
      "<style\\b[^<]*(?:(?!<\\/style>)<[^<]*)*<\\/style>",
      "<link\\b[^<]*(?:(?!<\\/link>)<[^<]*)*<\\/link>",
      "\\bjavascript:[^<]+",
      "data:text\\/html",
      "vbscript:[^<]+",
      "on[a-zA-Z]+=[\"'].*[\"']",
      "<[a-zA-Z]+[\\s\\S]*>"
  }
}

return _M
