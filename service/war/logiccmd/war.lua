local skynet = require "skynet"
local global = require "global"

function ConfirmRemote(mRecord, mData)
    local iWarId = mData.war_id
    local iType = mData.type
    local iSubType = mData.subtype
    local sName = mData.name

    global.oWarMgr:CreateWar(iWarId, iType, iSubType, sName)
end

function PrepareWar(mRecord, mData)
    local iWarId = mData.war_id
    local oWar = global.oWarMgr:GetWar(iWarId)
    assert(oWar)

    oWar:PrepareWar(mData.prepare_info)
end

function PrepareCamp(mRecord, mData)
    local iWarId = mData.war_id
    local oWar = global.oWarMgr:GetWar(iWarId)
    assert(oWar)

    oWar:PrepareCamp(mData.camp_id, mData.camp_info)
end

function AddPlayer(mRecord, mData)
    local iWarId = mData.war_id
    local oWar = global.oWarMgr:GetWar(iWarId)
    assert(oWar)
   
    local iCamp = mData.camp_id
    local mPlayer = mData.player
    local mSummInfo = mData.summ_info 
    oWar:AddPlayer(iCamp, mPlayer, mSummInfo)
end

function AddWarriorList(mRecord, mData)
    local iWarId = mData.war_id
    local oWar = global.oWarMgr:GetWar(iWarId)
    assert(oWar)
   
    local iCamp = mData.camp_id
    local lWarrior = mData.warrior_list
    oWar:AddWarriorList(iCamp, lWarrior)
end

function RemoveWar(mRecord, mData)
    local iWarId = mData.war_id
    global.oWarMgr:RemoveWar(iWarId)
end

function C2GSWarSkill(mRecord, mData)
    local iWarId = mData.war_id
    local oWar = global.oWarMgr:GetWar(iWarId)
    assert(oWar)

    local iWid = mData.net.wid
    local iSkill = mData.net.skill_id
    local iTarget = mData.net.target
    local mCmd = {
        cmd = "skill", 
        data = {
            skill_id = iSkill,
            target = iTarget,
        },
    }
    oWar:AddBoutCmd(iWid, mCmd)
end

function C2GSWarNormalAttack(mRecord, mData)
    local iWarId = mData.war_id
    local oWar = global.oWarMgr:GetWar(iWarId)
    assert(oWar)

    local iWid = mData.net.wid
    local mCmd = {
        cmd = "normal_attack",
        data = {
            target = mData.net.target,
        }
    }
    oWar:AddBoutCmd(iWid, mCmd)
end

