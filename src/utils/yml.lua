local M = {}
function M.read_file(file_path)
    local file = io.open(file_path, "r")
    if not file then
        error("无法打开文件: " .. file_path)
    end
    local content = file:read("*all")
    file:close()
    return content
end

function M.parse_yaml_line(line)
    local indent, key, value = string.match(line, "^(%s*)([%w_]+)%s*:%s*(.*)%s*$")
    if key and value then
        return #indent, key, value
    end
    local item_indent, item = string.match(line, "^(%s*)-%s*(.*)%s*$")
    if item then
        return #item_indent, nil, item
    end
    return nil, nil, nil
end

function M.parse_yaml(file_content)
    local data = {}
    local stack = { { data, 0 } }

    for line in file_content:gmatch("[^\r\n]+") do
        local indent, key, value = M.parse_yaml_line(line)
        if indent then
            while #stack > 1 and indent <= stack[#stack][2] do
                table.remove(stack)
            end

            local current = stack[#stack][1]

            if key then
                if value == "" then
                    current[key] = {}
                    table.insert(stack, { current[key], indent })
                else
                    current[key] = value
                end
            else
                table.insert(current, value)
            end
        end
    end

    return data
end


-- 打印解析结果
function M.print_table(t, indent)
    indent = indent or 0
    local prefix = string.rep("  ", indent)
    for k, v in pairs(t) do
        if type(k) == "number" then
            k = "-"  -- 用 '-' 来表示列表项
        end
        if type(v) == "table" then
            print(prefix .. k .. ":")
            M.print_table(v, indent + 1)
        else
            print(prefix .. k .. ": " .. tostring(v))
        end
    end
end

-- print_table(data)

return M