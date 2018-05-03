local skynet = require "skynet"
local global = require "global"

function RemoteWarEnd(mRecord, mData)
    local iWarId = mData.war_id
    local mWarEnd = mData.war_end

    global.oWarMgr:WarEnd(iWarId, mWarEnd)
end

function RemoteLeavePlayer(mRecord, mData)
    local iWarId = mData.war_id
    local iPid = mData.pid
    local bEscape = mData.escape

    global.oWarMgr:RemoteLeavePlayer(iWarId, iPid, bEscape)
end
