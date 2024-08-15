local _M = {
    name = "Backup File",
    desc = "检测是否存在不安全的备份文件暴露在应用程序中，包括隐藏文件。",
    level = "medium",
    position = "uri",
    rules = {
        {
            pattern = [[ \.(bak[0-9]*|backup[0-9]*|old[0-9]*|orig|copy|save|tmp|temp|swp[0-9]*|sql[0-9]*|db[0-9]*|sqlite[0-9]*|log[0-9]*|1|part|crdownload|dmp|~|\.~[0-9]*~|bak~|old~|tmp~)(?![\w.;/\\-]) ]],
            
            name = "Common Backup and Temporary File Extensions",
            confidence = 3
        },
        {
            pattern = [[ (backup|bak|old|www|site|web|archive|copy|stored|saved|temp|temporary|dump|data|test)[0-9]*\.(tar|gz|zip|rar|7z|tgz)(?![\w.;/\\-]) ]],
            name = "Unsecure Compressed Backup Files",
            confidence = 3
        },
        
        {
            pattern = [[ \.(?:git|env|htaccess|config|svn|DS_Store|bzr|cvs|hg|npmrc|yarnrc|editorconfig|eslintignore|prettierignore|dockerignore|gitignore|gitattributes|gitmodules|credentials|aws|bashrc|bash_profile|bash_logout|inputrc|nanorc|profile|tmux\.conf|vimrc|zshrc|zprofile|zlogin|zlogout|zpreztorc)(?![\w.;/\\-]) ]],
            name = "Hidden Files",
            confidence = 3
        },
    }
}

return _M
