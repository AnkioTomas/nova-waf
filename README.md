# Nova-WAF

![License](https://img.shields.io/badge/license-MIT-blue.svg) ![Version](https://img.shields.io/badge/version-1.0.0-brightgreen.svg) ![OpenResty](https://img.shields.io/badge/OpenResty-1.19.3.1-orange.svg)


## 概述

Nova-WAF 是一个基于 OpenResty 和 Lua 脚本的 Web 应用防火墙 (WAF)。该项目旨在提供一种高效且可扩展的方式来保护 Web 应用免受各种网络攻击，如 SQL 注入、XSS 攻击、DDoS 攻击等。

## 特性

- **高性能**：利用 OpenResty 的高效处理能力，保证高并发下的快速响应。
- **可扩展**：通过 Lua 脚本实现灵活的规则配置和自定义检测逻辑。
- **丰富的规则集**：内置多种常见攻击检测规则，支持用户自定义扩展。
- **易于部署**：简单配置即可集成到现有的 OpenResty/Nginx 环境中。

## 安装

### 先决条件

- 安装 OpenResty
- LuaJIT 2.1+
- 配置 Nginx

### 步骤

1. 克隆项目代码：
   ```bash
   git clone https://github.com/AnkioTomas/nova-waf.git
   cd nova-waf
   ```

2. 将 WAF 脚本文件复制到 OpenResty：
   ```bash
   cp -r ./src /usr/local/openresty/waf/
   ```

3. 配置 Nginx：
   编辑 Nginx 配置文件 `nginx.conf`，在 `http` 块中添加以下内容：
   ```nginx
    include /usr/local/openresty/waf/conf.d/http.conf;
   ```
   如果你需要调试，请将日志级别调整为`debug`,否则看不到日志。
   ```nginx
   error_log  /usr/local/openresty/nginx/logs/error.log debug;
   ```

## 使用
### WAF 配置

Nova-Waf的配置文件位于`src/conf.d/waf.conf`，以下是具体的配置说明：

```lua
# monitor：检测模式，protection：防护模式，off：关闭waf
mode = "protection"

# debug
debug = "on"

# waf日志文件路径
log_path = "/usr/local/openresty/nginx/logs/waf/"

# ip禁止访问时间，单位是秒，如果设置为0则永久禁止
ip_ban_time = 0

# 置信度相关配置
possibly_timeout = 300  # 5分钟内疑似攻击行为次数，超过该次数后将被禁止访问
possibly_count = 3      # 疑似攻击行为置信度，超过该值后将返回403，取值范围为 1 低 2 中 3 高

# 恶意行为相关配置
block_timeout = 600     # 发现恶意行为后，禁止访问10分钟
block_count = 10        # 恶意行为次数，超过该次数后将被禁止访问
block_time = 600        # 恶意行为检测时间，单位是秒，默认是10分钟

# 检测规则
exp_backup = "on"       # 开启备份路径检测规则
exp_cmd = "on"          # 开启命令注入检测规则
exp_dns = "on"          # 开启DNS攻击检测规则
exp_ldap = "on"         # 开启LDAP注入检测规则
exp_path = "on"         # 开启路径遍历检测规则
exp_sensitive = "on"    # 开启敏感信息检测规则
exp_sqli = "on"         # 开启SQL注入检测规则
exp_ssrf = "on"         # 开启SSRF攻击检测规则
exp_xss = "on"          # 开启跨站脚本攻击检测规则
exp_xxe = "on"          # 开启XML外部实体攻击检测规则
exp_bot = "on"          # 开启恶意机器人检测规则

# 请求体最大是多少，单位是字节，默认是50M
body_max_size = 52428800

# 最大解码次数，默认是10次
decode_max_count = 10

# cc攻击拦截
cc_defence = "off"      # 关闭CC攻击防护
cc_limit = 100          # CC攻击访问频率
cc_seconds = 60         # CC攻击时间窗口

```

### 拦截页面配置

Nova-Waf的拦截页面文件位于`src/conf.d/403.html`，可以根据业务需求自由修改。

### 黑白名单

Nova-Waf的黑名单和白名单位于`src/conf.d/blackIp`和`src/conf.d/whiteIp`文件，一行一个支持带子网掩码，例如：`1.1.1.0/24`。

### 配置规则

Nova-WAF 支持通过 Lua 脚本自定义规则。默认的规则配置文件位于 `src/rules/` 目录下。用户可以根据需要修改或添加规则文件。

### 示例规则

以下是一个简单的 SQL 注入检测规则示例：
```lua
local _M = {
  name = "SSRF",
  desc = "SSRF是一种常见的攻击手段，通过在输入框中输入URL，获取服务器的内部信息。",
  level = "high", -- 威胁等级
  position = "all", -- 作用区域，仅支持 headers字段，详细可参考bot规则
  rules = {
    {
      pattern = [[ (gopher|doc|php|glob|file|phar|zlib|ftp|ldap|dict|ogg|data|smb|tftp|rsync|telnet|jdbc|rmi|dns|ws|wss|sftp): ]], -- 匹配正则
      name = "Potential SSRF URL", -- 规则名称
      confidence = 3 -- 置信度，只有三个值 1 2 3
    }
  }
}

return _M

```

## 贡献

欢迎任何形式的贡献！如果你有新的规则、功能建议或发现了 bug，请提交 issue 或发起 pull request。

## 许可证

Nova-WAF 采用 MIT 许可证，详情请参见 LICENSE 文件。

## 联系

如有任何问题或建议，请通过以下方式联系我们：
- Email: ankio@ankio.net
---

感谢你对 Nova-WAF 项目的关注和支持！