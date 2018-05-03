local protobuf = require "base.protobuf"


local M = {}
local netdefines = {}

function M.Init()
    local fp = io.open("./proto/proto.pb", "rb")
    local data = fp:read("a")
    fp:close()
    protobuf.register(data)

    local env = setmetatable({}, {__index = _G})
    local fp = io.open("proto/netdefines.lua", "rb")
    local data = fp:read("a")
    fp:close()
    local f, s = load(data, "netdefines", "bt", env)
    assert(f, s)
    netdefines = f()
end

function M.FindC2GSProtoByName(sMessage)
    return netdefines.C2GSProto2Index[sMessage]
end

function M.FindC2GSProtoByIndex(iProto)
    return netdefines.C2GSIndex2Proto[iProto]
end

function M.FindGS2CProtoByName(sMessage)
    return netdefines.GS2CProto2Index[sMessage]
end

function M.FindGS2CProtoByIndex(iProto)
    return netdefines.GS2CIndex2Proto[iProto]
end

return M

