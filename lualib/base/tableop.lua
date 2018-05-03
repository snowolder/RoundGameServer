
function table_key_list(tbl)
    local l = {}
    for k, v in pairs(tbl) do
        table.insert(l, k)
    end
    return l
end

function table_value_list(tbl)
    local l = {}
    for k, v in pairs(tbl) do
        table.insert(l, v)
    end
    return l
end

function table_copy(tbl)
    local res = {}
    for k, v in pairs(tbl) do
        res[k] = v
    end
    return res
end

function table_deep_copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
        copy = {}
        for orig_key, orig_val in next, orig, nil do
            copy[table_deep_copy(orig_key)] = table_deep_copy(orig_val)
        end
        setmetatable(copy, table_deep_copy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function table_serialize(tbl, visited)
    visited = visited or {}
    local con = "{"
    for k, v in pairs(tbl) do
        if not visited[k] or visited[k] ~= v then
            visited[k] = v
            if type(k) == "table" then
                con = con.."["..table_serialize(k, visited).."] = "
            elseif type(k) == "number" then
                con = con.."["..tostring(k).."] = "
            else
                con = con..tostring(k).." = "
            end
            if type(v) == "table" then
                con = con..table_serialize(v, visited)
            else
                con = con .. tostring(v)
            end
            con = con .. ", "
        end
    end
    con = con .. "}"
    return con
end

function list_combine(l1, l2)
    for _, val in ipairs(l2) do
        l1[#l1+1] = val
    end
end

function table_count(t)
    local cnt = 0
    for k, v in pairs(t) do
        cnt = cnt + 1
    end
    return cnt
end
