local M = {}


function ngx(msg)
    if ngx then
        ngx.log(ngx.INFO, msg)
    else
        print(msg)
    end
end


function attack()
    
end

return M