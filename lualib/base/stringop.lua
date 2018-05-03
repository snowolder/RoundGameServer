local fm = {}
function formula_string(msg, env)
    if fm[msg] then
        return fm[msg]()
    end
    fm[msg] = load(string.format([[
        for k, v in pairs(env) do
            _ENV[k] = v
        end
        return (%s)
    ]], msg), msg, "bt", {env=env, math=math, pairs=pairs})
    return fm[msg]()
end

function split(str, sep, plain)
    local b, res = 0, {}
    sep = sep or "%s+"

    if #sep == 0 then
        for i = 1, #str do
            res[#res + 1] = string.sub(str, i, i)
        end
        return res
    end

    while b <= #str do
        local e, e2 = string.find(str, sep, b, plain)
        if e then
            res[#res+1] = string.sub(str, b, e-1)
            b = e2 + 1
            if b > #str then res[#res+1] = "" end
        else
            res[#res+1] = string.sub(str, b)
            break
        end
    end
    
    return res
end

function trim(s)
  return s:match'^%s*(.*%S)%s*$' or ''
end

function replace_vars(str, vars)
    --replace_var("hello {name}", {name="world"})
    if not vars then
        vars = str
        str = vars[1]
    end
    return (string_gsub(str, "({([^}]+)})",
        function(whole,i)
            return vars[i] or whole
        end))
end

