local _M = {
  name = "敏感信息",
  desc = "检测是否存在敏感文件暴露在应用程序中。",
  level = "medium",
  position = "all",
  rules = {
      "(config|settings|database|env|plist)%.(xml|json|ini|cfg|conf|properties|yml)",
      "(key|cert|pem|rsa|id_rsa|id_dsa)%.(pub|pem|key)",
      "(password|passwd|credentials|secret|token)%.(txt|csv|log|doc|xls|xlsx|pdf|json|yaml|yml)",
      "(backup|bak|old|log|dat|db)%.(xml|json|ini|cfg|conf|properties|yml|txt|csv|log|doc|xls|xlsx|pdf|dat|db)"
  }
}

return _M