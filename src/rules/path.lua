local _M = {
  name = "Path Overflow",
  desc = "检测是否允许用户通过输入访问系统文件系统中的未经授权的文件或目录。",
  level = "medium",
  position = "all",
  rules = {
    {
      pattern = [[ /\.\./ ]],
      name = "Parent Directory Traversal (/../)",
      confidence = 1
    },
    {
      pattern = [[ \.\./]],
      name = "Parent Directory Traversal (../)",
      confidence = 1
    },
  }
}

return _M
