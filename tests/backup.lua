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
    "testfile.bak",
    "testfile.bak1",
    "testfile.backup",
    "testfile.backup2",
    "testfile.old",
    "testfile.old3",
    "testfile.orig",
    "testfile.copy",
    "testfile.save",
    "testfile.tmp",
    "testfile.temp",
    "testfile.swp",
    "testfile.tgz",
    "testfile.sql",
    "testfile.db",
    "testfile.sqlite",
    "testfile.log",
    "testfile.1",

    -- Unsecure Compressed Backup Files
    "backupfile.tar",
    "backupfile.gz",
    "backupfile.zip",
    "backupfile.rar",
    "backupfile.7z",
    "backupfile.tgz",
    "bakfile0.tar",
    "bakfile1.gz",
    "oldfile2.zip",
    "wwwfile3.rar",

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