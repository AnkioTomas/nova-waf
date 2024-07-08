local _M = {
    name = "Backup File",
    desc = "检测是否存在不安全的备份文件暴露在应用程序中，包括隐藏文件。",
    level = "medium",
    location = "all",
    rules = {
        {
            pattern = [[ \.(bak[0-9]*|backup[0-9]*|old[0-9]*|orig|copy|save|tmp|temp|swp|tgz|sql|db|sqlite|log|1) ]],
            name = "Common Backup File Extensions",
            confidence = 9
        },
        {
            pattern = [[ (backup|bak|old|www)[0-9]*\.(tar|gz|zip|rar|7z|tgz) ]],
            name = "Unsecure Compressed Backup Files",
            confidence = 9
        },
        {
            pattern = [[ \.(?:git|env|htaccess|config|svn|DS_Store|bzr|cvs|hg|npmrc|yarnrc|editorconfig|eslintignore|prettierignore|dockerignore|gitignore|gitattributes|gitmodules|credentials|aws|bashrc|bash_profile|bash_logout|inputrc|nanorc|profile|tmux\.conf|vimrc|zshrc|zprofile|zlogin|zlogout|zpreztorc) ]],
            name = "Hidden Files",
            confidence = 8
        }
    }
}

return _M
