local _M = {
  name = "SSRF",
  desc = "SSRF是一种常见的攻击手段，通过在输入框中输入URL，获取服务器的内部信息。",
  level = "high",
  position = "all",
  rules = {
      "(gopher|doc|php|glob|file|phar|zlib|ftp|ldap|dict|ogg|data|http|https|smb|tftp|rsync|telnet|jdbc|rmi|dns|ws|wss|sftp)://"
  }
}

return _M
