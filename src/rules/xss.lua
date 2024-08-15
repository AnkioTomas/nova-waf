local _M = {
  name = "XSS",
  desc = "XSS是一种常见的攻击手段，通过在输入框中输入JavaScript代码，获取用户的Cookie信息。",
  level = "medium",
  position = "uri,body",
  rules = {
    {
      pattern = [[ <script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script> ]],
      name = "Script Tag Injection",
      confidence = 3
    },
    {
      pattern = [[ <iframe\b[^<]*(?:(?!<\/iframe>)<[^<]*)*<\/iframe> ]],
      name = "Iframe Tag Injection",
      confidence = 3
    },
    {
      pattern = [[ <object\b[^<]*(?:(?!<\/object>)<[^<]*)*<\/object> ]],
      name = "Object Tag Injection",
      confidence =3
    },
    {
      pattern = [[ <embed\b[^<]*(?:(?!<\/embed>)<[^<]*)*<\/embed> ]],
      name = "Embed Tag Injection",
      confidence =3
    },
    {
      pattern = [[ <style\b[^<]*(?:(?!<\/style>)<[^<]*)*<\/style> ]],
      name = "Style Tag Injection",
      confidence =3
    },
    {
      pattern = [[ <link\b[^<]*(?:(?!<\/link>)<[^<]*)*<\/link> ]],
      name = "Link Tag Injection",
      confidence = 3
    },
    {
      pattern = [[ \bjavascript:[^<]+ ]],
      name = "Javascript URI",
      confidence =3
    },
    {
      pattern = [[ data:text/html ]],
      name = "Data URI",
      confidence = 2
    },
    {
      pattern = [[ vbscript:[^<]+ ]],
      name = "VBScript URI",
      confidence = 2
    },
    {
      pattern = [[ <.+on\w+= ]],
      name = "Event Handler Injection",
      confidence = 3
    },
    {
      pattern = [[ <[a-zA-Z]+[\s\S]*>]],
      name = "HTML Tag Injection",
      confidence = 3
    },
    {
      pattern = [[ href(.+)javascript: ]],
      name = "Encoded JavaScript URL",
      confidence = 3
    }
  }
}

return _M
