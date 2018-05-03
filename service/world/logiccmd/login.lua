local global = require "global"

function LoginPlayer(mRecord, mData)
    local iPid = mData.pid
    local mRole = mData.role
    global.oWorldMgr:LoginPlayer(iPid, mRole)
end

function KickConnection(mRecord, mData)
    local iFd = mData.fd
    global.oConnMgr:DelConnectionByFd(iFd)
end
