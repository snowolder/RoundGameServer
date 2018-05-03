local module = {}

function import(dotfile)
   if module[dotfile] then
        return module[dotfile]
    end

    local file_name = string.gsub(dotfile, "%.", "/") .. ".lua"
    local m = setmetatable({}, {__index = _G})
    local f = loadfile_ex(file_name, "rb", m)
    f()
    module[dotfile] = m
    return m
end

function reload(dotfile)
    if not module[dotfile] then
        return
    end

    local new_m = module[dotfile]
    local bak_m = table_copy(new_m)
    local file_name = string.gsub(dotfile, "%.", "/") .. ".lua"
    local f = loadfile_ex(file_name, "rb", new_m)
    if not f then return end
    f()

    local visited, recu = {}, nil
    recu = function(old, new)
        for k, v in pairs(new) do
            if not visited[k] then
                visited[k] = true
                if type(old[k]) == "table" and type(new[k]) == "table" then
                    recu(old[k], new[k])
                else
                    old[k] = v
                end
            end
        end
        for k, v in pairs(old) do
            if not visited[k] and not rawget(new, k) then
                visited[k] = true
                old[k] = nil
            end
        end
    end

    local ret, msg = pcall(function()
        for k, v in pairs(new_m) do
            if type(v) == "table" and type(bak_m[k]) == "table" then
                recu(bak_m[k], v)
                new_m[k] = bak_m[k]
            end
        end
    end)

    if not ret then
        print("reload fail:",  msg)
        --TODO need return back
        print("return back success")
    else
        print("reload success:", file_name)
    end
end
