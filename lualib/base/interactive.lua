--------------------------------
----------跨服务通信------------
--------------------------------

local skynet = require "skynet"

local M = {}
local logic_cmd = {}
local session_idx = 0
local session_keep = {}

local function dispatch_session()
    session_idx = session_idx + 1
    if session_idx > 0x7fffffff then
        session_idx = 1
    end
    return session_idx
end

function M.dispatch_logic(m)
    logic_cmd = m

    skynet.register_protocol(
        {
            name = "logic",
            id = skynet.PTYPE_LOGIC,
            pack = skynet.pack,
            unpack = skynet.unpack,
        }
    )

    skynet.dispatch("logic", function(session, source, record, args)
        if record.type == "response" then
            local session_idx = record.session
            local callback = session_keep[session_idx]
            assert(callback)
            safe_call(callback, record, args)
        else
            local mod, func = record.mod_name, record.fun_name
            if mod == "default" then
                safe_call(M[func], record, args)
            elseif record.type == "send" then
                safe_call(logic_cmd.Invoke, mod, func, record, args)
            else
                safe_call(logic_cmd.Invoke, mod, func, record, args)
            end
        end
    end)
end

function M.send(addr, module, func, args)
    local record = {
        mod_name = module,
        fun_name = func,
        type = "send",
        source = "."..MY_ADDR,
        session = 0,
    }
    skynet.send(addr, "logic", record, args)
end

function M.request(addr, module, func, args, callback)
    local session_idx = dispatch_session()
    session_keep[session_idx] = callback
    local record = {
        session = session_idx,
        source = "."..MY_ADDR,
        mod_name = module,
        fun_name = func,
        type = "request",
    }
    skynet.send(addr, "logic", record, args)
end

function M.respond(addr, session_idx, args)
    local record = {
        session = session_idx,
        type = "response",
        source = "."..MY_ADDR,
    }
    skynet.send(addr, "logic", record, args)
end

function M.ExecuteString(record, args)
    local m = setmetatable({}, {__index = _G})
    local f, s = load(args, "ExecuteString", "bt", m)
    if f then
        f()
    end
end

return M
