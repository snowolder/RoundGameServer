local netpack = require "netpack"
local global = require "global"
local gateobj = import(service_path("gateobj"))

local M = {}

function M.open(iAddr, iFd, sData)
    local sIp, sPort = string.match(sData, "(%d+.%d+.%d+.%d+):(%d+)")
    local iPort = tonumber(sPort)

    local oConn = gateobj.NewConnection(iAddr, iFd, iPort)
    global.oGateMgr:AddConnection(oConn)
end

function M.close(iAddr, iFd)
    global.oGateMgr:RemoveConnection(iFd)
end


function Invoke(session, source, msg, sz)
    --format: 5 open 5 127.0.0.1:57628:0
    local iAddr = source
    local sData = netpack.tostring2(msg, sz)
    local sFd, sCmd = string.match(sData, "(%d+) (%a+)")

    if M[sCmd] then
        safe_call(M[sCmd], iAddr, tonumber(sFd), sData)
    end
end

