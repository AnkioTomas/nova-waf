local _M = {
    name = "备份文件",
    desc = "检测是否存在不安全的备份文件暴露在应用程序中，包括隐藏文件。",
    level = "medium",
    location = "all",
    rules = {
        -- 检测常见的备份文件后缀
        "%.(bak[0-9]*|backup[0-9]*|old[0-9]*|orig|copy|save|tmp|temp|swp|tar|gz|zip|rar|7z|tgz|sql|db|sqlite|log|1)$",
        -- 检测隐藏文件
        "^%.(git|env|htaccess|config|svn|DS_Store|bzr|cvs|hg|npmrc|yarnrc|editorconfig|eslintignore|prettierignore|dockerignore|gitignore|gitattributes|gitmodules|credentials|aws|bashrc|bash_profile|bash_logout|inputrc|nanorc|profile|tmux%.conf|vimrc|zshrc|zprofile|zlogin|zlogout|zpreztorc)$"
    }
}

return _M
