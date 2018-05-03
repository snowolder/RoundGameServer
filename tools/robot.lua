package.cpath = package.cpath..";./skynet/luaclib/?.so;".."./skynet/cservice/?.so"
package.path = package.path..";./lualib/?.lua;".."./skynet/lualib/?.lua;".."./tools/?.lua"

--local skynet = require "skynet"
require "base.tableop"
require "base.stringop"
local socket = require "clientsocket"
local protobuf = require "base.protobuf"
local netpack = require "netpack"
local netfind = require "base.netfind"
netfind.Init()

tprint = function(...)
    local info_list = table.pack(...)
    local ret_list = {}
    for i = 1, #info_list do
        if info_list[i] == "nil" then
            table.insert(ret_list, "nil")
        elseif type(info_list[i]) == "table" then
            table.insert(ret_list, table_serialize(info_list[i]))
        else
            table.insert(ret_list, info_list[i])
        end
    end
    print(table.unpack(ret_list))
end

function loadfile_ex(file_name, mode, env)
    mode = mode or "rb"
    local fp = io.open(file_name, mode)
    local data = fp:read("a")
    fp:close()
    local f, s = load(data, file_name, "bt", env)
    assert(f, s)
    return f
end

trace_msg = function(msg)
    print(debug.traceback("=====" .. msg .. "====="))
end

safe_call = function(func, ...)
    xpcall(func, trace_msg, ...)
end


robot = {}
robot.__index = robot

function robot:new(ip, port)
    local o = setmetatable({}, self)
    o.ip = ip
    o.port = port
    o.runing = true
    o.fd = socket.connect(ip, port)
    o.coroutines = {}
    o.last = ""
    o.server_proto_handle = {}
    return o
end

function robot:fork(func, ...)
    local args = {...}
    local co = coroutine.create(function()
        safe_call(func, table.unpack(args))
    end)
    table.insert(self.coroutines, co)
end

function robot:run_script(client_script)
    print("run_script:"..client_script)
    local m = setmetatable({client = self}, {__index = _G})
    local f = loadfile_ex(client_script, "rb", m)
    safe_call(f)
end

function robot:start()
    self:fork(self.check_socket_io, self)
    while true do
        --self:check_socket_io()

        local dead_list = {}
        for idx, co in ipairs(self.coroutines) do
            if coroutine.status(co) == "dead" then
                table.insert(dead_list, idx)
            end
        end
        for i = #dead_list, 1, -1 do
            table.remove(self.coroutines, dead_list[i])
        end
        for idx, co in ipairs(self.coroutines) do
            coroutine.resume(co)
        end
        coroutine.yield()
    end
end

function robot:check_socket_io()
    local func = function()
        self:check_receive_msg()
        self:check_client_console()
    end
    while self.runing do
        safe_call(func)
        coroutine.yield()
    end
end

function robot:check_receive_msg()
    while true do
        local buff = self:recv_package()
        if not buff then
            break
        end
        local cmd, args = self:s2c_unpack_buff(buff)
        print("receive_msg", cmd, table_serialize(args))
        local func = self.server_proto_handle[cmd]
        if func then
            safe_call(func, self, args)
        end
    end
end

function robot:recv_package()
    local result
    result, self.last = self:unpack_package(self.last)
    if result then
        return result
    end
    local r = socket.recv(self.fd)
    if not r then
        return nil
    end
    if r == "" then
        print("Server closed")
        os.exit()
    end
    print(r)
    result, self.last = self:unpack_package(self.last .. r)
    return result
end

function robot:unpack_package(text)
	local size = #text
	if size < 2 then
		return nil, text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s+2 then
		return nil, text
	end

	return text:sub(3,2+s), text:sub(3+s)
end

function robot:s2c_unpack_buff(buff)
    local proto_no = 0
    for i = 1, 2 do
        proto_no = proto_no | string.byte(buff, i, i) << 8*(i-1)
    end
    local mod, message = table.unpack(netfind.FindGS2CProtoByIndex(proto_no))
    proto = protobuf.decode(message, string.sub(buff, 3))
    return message, proto
end

function robot:check_client_console()
    local msg = socket.readstdin()
    if not msg then return end

    local cmd, args = self:parsecmd(msg)
    if cmd and args and type(args) == "table" then
        self:run_cmd(cmd, args)
    end
end

function robot:parsecmd(msg)
    --format:C2GSRunCmd {cmd = 'login'}
    local cmd = string.match(msg, "%w+")
    local args = string.sub(msg, #cmd+2, #msg)
   
    args = formula_string(args, {}) 
    return cmd, args
end

function robot:run_cmd(cmd, args)
    local buff = self:c2s_package(cmd, args)
    socket.send(self.fd, buff)
end

function robot:c2s_package(message, data)
    local buff = protobuf.encode(message, data)
    local proto = netfind.FindC2GSProtoByName(message)
    assert(proto, "can't find message"..message)

    local proto_list = {}
    for i = 1, 2 do
        table.insert(proto_list, string.char(proto % 256))
        proto = proto >> 8
    end
    table.insert(proto_list, buff)
    return string.pack(">s2", table.concat(proto_list, ""))
end

