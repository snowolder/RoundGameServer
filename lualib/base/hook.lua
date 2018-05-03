local M = {}

local logic_func = nil

function M.finish_hook()
    if logic_func then
        safe_call(logic_func)
    end
end

function M.set_logic_func(func)
    logic_func = func
end

return M
