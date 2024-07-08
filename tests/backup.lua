local subname = ""
-- 发送 GET 请求
local response = nil

local misleading_urls = {
    "index.bak.html",
    "main.backup.js",
    "styles.old.css",
    "logo.copy.png",
    "app.temp.apk",
    "document.swp.pdf",
    "profile.tgz.jpg",
    "data.sql.xml",
    "README.bak.md"
}


for _, test_url in ipairs(misleading_urls) do
    subname = "Common Backup File Extensions - "..test_url
    response = client:get(url .. "/?file=" .. test_url)
    assertAll(response.body, "hello, world", response.status, "200 OK", TEST_CASE..subname)
end

local test_urls = {
    -- Common Backup File Extensions
    "test.bak",
    "test.bak1",
    "test.backup",
    "test.backup2",
    "test.old",
    "test.old3",
    "test.orig",
    "test.copy",
    "test.save",
    "test.tmp",
    "test.temp",
    "test.swp",
    "test.tgz",
    "test.sql",
    "test.db",
    "test.sqlite",
    "test.log",
    "test.1",

    -- Unsecure Compressed Backup Files
    "backup.tar",
    "backup.gz",
    "backup.zip",
    "backup.rar",
    "backup.7z",
    "backup.tgz",
    "bak0.tar",
    "bak1.gz",
    "old2.zip",
    "www3.rar",

    -- Hidden Files
    ".git",
    ".env",
    ".htaccess",
    ".config",
    ".svn",
    ".DS_Store",
    ".bzr",
    ".cvs",
    ".hg",
    ".npmrc",
    ".yarnrc",
    ".editorconfig",
    ".eslintignore",
    ".prettierignore",
    ".dockerignore",
    ".gitignore",
    ".gitattributes",
    ".gitmodules",
    ".credentials",
    ".aws",
    ".bashrc",
    ".bash_profile",
    ".bash_logout",
    ".inputrc",
    ".nanorc",
    ".profile",
    ".tmux.conf",
    ".vimrc",
    ".zshrc",
    ".zprofile",
    ".zlogin",
    ".zlogout",
    ".zpreztorc"
}

for _, test_url in ipairs(test_urls) do
    subname = "Injection Backup File Extensions - "..test_url
    response = client:get(url .. "/?file=" .. test_url)
    assertAll(response.body, "Backup File", response.status, "403 Forbidden", TEST_CASE..subname)
end