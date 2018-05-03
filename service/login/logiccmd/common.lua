local skynet = require "skynet"
local global = require "global"

function KickConnection(mRecord, mData)
    local iFd = mData.fd
    global.oGateMgr:RemoveConnection(iFd)
end
