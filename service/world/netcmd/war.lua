local skynet = require "skynet"
local global = require "global"

function C2GSWarSkill(oPlayer, mData)
    local iWarId = oPlayer:GetWarId()
    if not iWarId then return end

    local iPid = oPlayer:GetPid()
    global.oWarMgr:WarSkill(iWar, iPid, mData)
end

function C2GSWarNormalAttack(oPlayer, mData)
    local iWarId = oPlayer:GetWarId()
    if not iWarId then return end

    local iPid = oPlayer:GetPid()
    global.oWarMgr:WarNormalAttack(iWarId, iPid, mData)
end

