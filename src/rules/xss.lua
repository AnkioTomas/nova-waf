local _M = {
  name = "XSS",
  desc = "XSS是一种常见的攻击手段，通过在输入框中输入JavaScript代码，获取用户的Cookie信息。",
  level = "medium",
  position = "all",
  rules = {
    {
      pattern = [[ <script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script> ]],
      name = "Script Tag Injection",
      confidence = 9
    },
    {
      pattern = [[ <iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe> ]],
      name = "Iframe Tag Injection",
      confidence = 9
    },
    {
      pattern = [[ <object\b[^<]*(?:(?!<\/object>)<[^<]*)*<\/object> ]],
      name = "Object Tag Injection",
      confidence =9
    },
    {
      pattern = [[ <embed\b[^<]*(?:(?!<\/embed>)<[^<]*)*<\/embed> ]],
      name = "Embed Tag Injection",
      confidence =9
    },
    {
      pattern = [[ <style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style> ]],
      name = "Style Tag Injection",
      confidence =9
    },
    {
      pattern = [[ <link\b[^<]*(?:(?!<\/link>)<[^<]*)*<\/link> ]],
      name = "Link Tag Injection",
      confidence = 9
    },
    {
      pattern = [[ \bjavascript:[^<]+ ]],
      name = "Javascript URI",
      confidence =8
    },
    {
      pattern = [[ data:text/html ]],
      name = "Data URI",
      confidence = 8
    },
    {
      pattern = [[ vbscript:[^<]+ ]],
      name = "VBScript URI",
      confidence = 8
    },
    {
      pattern = [[ on[a-zA-Z]+=[\"'].*[\"'] ]],
      name = "Event Handler Injection",
      confidence = 8
    },
    {
      pattern = [[ <[a-zA-Z]+[\s\S]*>]],
      name = "HTML Tag Injection",
      confidence = 4
    }
  }
}

return _M
