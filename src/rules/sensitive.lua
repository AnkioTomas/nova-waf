local _M = {
  name = "Sensitive File Exposure",
  desc = "检测是否存在敏感文件暴露在应用程序中。",
  level = "medium",
  position = "all",
  rules = {
    {
      pattern = [[ (config|settings|database|env|plist)\.(xml|json|ini|cfg|conf|properties|yml) ]],
      name = "Configuration File Exposure",
      confidence = 2
    },
    {
      pattern = [[ (key|cert|pem|rsa|id_rsa|id_dsa)\.(pub|pem|key) ]],
      name = "Key or Certificate File Exposure",
      confidence = 2
    },
    {
      pattern = [[ (password|passwd|credentials|secret|token)\.(txt|csv|log|doc|xls|xlsx|pdf|json|yaml|yml) ]],
      name = "Password or Credentials File Exposure",
      confidence =2
    },
    {
      pattern = [[ (backup|bak|old|log|dat|db)\.(xml|json|ini|cfg|conf|properties|yml|txt|csv|log|doc|xls|xlsx|pdf|dat|db) ]],
      name = "Backup or Log File Exposure",
      confidence = 2
    }
  }
}

return _M
