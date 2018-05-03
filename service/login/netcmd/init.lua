local skynet = require "skynet"
local global = require "global"

local mCmd = {}
mCmd.login = import(service_path("netcmd.login"))

function Invoke(sMod, sMsg, fd, mData)
    local oConn = global.oGateMgr:GetConnection(fd)
    if oConn then
        safe_call(mCmd[sMod][sMsg], oConn, mData)
    else
        skynet.error("not connection fd:" .. fd)
    end
end
