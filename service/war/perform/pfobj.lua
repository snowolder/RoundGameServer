local skynet = require "skynet"
local global = require "global"
local share = require "base.share"
local baseobj = import(lualib_path("base.baseobj"))

function NewPerform(iPerform, mPerform)
    return CPerform:New(iPerform, mPerform)
end

CPerform = {}
CPerform.__index = CPerform
inherit(CPerform, baseobj.CBaseObj)

function CPerform:New(iPerform, mPerform)
    local o = super(CPerform).New(self)
    o.m_iPerform = iPerform
    o.m_mInfo = mPerform
    return o
end

function CPerform:GetLevel()
    return self:GetInfo("level", 0)
end

function CPerform:Perform(oAttack, iTarget)
    local oWar = oAttack:GetWarObj()
    assert(oWar)

    local lVictim = self:PerformTarget(oAttack, iTarget)
    if #lVictim <= 0 then
        return
    end

    local bResume, mResume = self:CheckResume(oAttack)
    if not bResume then
        return
    end

    self:DoResume(oAttack, mResume)
    self:DoPerform(oAttack, lVictim)
    self:EndPerform(oAttack, lVictim)
end

function CPerform:PerfromTarget(oAttack, iTarget)
    local iRange = self:PerformRange(oAttack)
    local iStatus = self:PerformTargetStatus()
    local lTarget = {}
    local lWarrior = {}
    if self:PerformTargetType() == defines.PERFORM_TARGET_TYPE.FRIEND then
        local lWarrior = oAttack:GetFriendList(true)
    else
        local lWarrior = oAttack:GetEnemyList(true)
    end
    for iWid, oWarrior in pairs(lWarrior) do
        if oWarrior:Status() == iStatus then
            table.insert(lTarget, iWid)
            if #lTarget >= iRange then
                break
            end
        end
    end
    return lWarrior
end

function CPerform:CheckResume(oAttack)
    local mResume = self:PerformResume(oAttack)
    for sKey, iVal in pairs(mResume) do
        if oAttack:GetInfo(sKey, 0) < iVal then
            return false, mResume
        end
    end
    return true, mResume
end

function CPerform:DoResume(oAttack, mResume)
    for sKey, iVal in pairs(mResume) do
        local iCurr = oAttack:GetInfo(sKey, 0)
        iCurr = math.max(0, iCurr-iVal)
        oAttack:SetInfo(sKey, iCurr)
    end
    oAttack:RefreshClientProp(mResume, true)
end

function CPerform:DoPerform(oAttack, lVictim, mArgs)
    --TODO sync to client
    local oWar = oAttack:GetWarObj()
    assert(oWar)

    local mNet = {
        war_id = oWar:GetWarId(),
        bout = oWar:GetBout(),
        skill_id = self.m_iPerform,
        attack = oAttack:GetWid(),
        victim_list = lVictim,
    }
    oWar:BroadCast("GS2CWarSkill", mNet)
    
    local iType = self:PerformType()
    for _, iVictim in ipairs(lVictim) do
        self:TruePerform(oAttack, iVictim, mArgs)
    end 
end

function CPerform:TruePerform(oAttack, iVictim, mArgs)
    local oWar = oAttack:GetWarObj()
    assert(oWar)

    local oVictim = oWar:GetWarrior(iVictim)
    if not oVictim then return end

    if iType == defines.PERFORM_TYPE.PHY_ATTACK then
        global.oActionMgr:TryPhyAttack(oAttack, oVictim, mArgs)
    --TODO elseif 
    end
end

function CPerform:EndPerform(oAttack, lVictim)
end

function CPerform:PerformType()
    --物理，法术，封印
    local mPerform = self:GetPerformInfo()
    return mPerform.perform_type
end

function CPerform:PerformRange(oAttack)
    local mPerform = self:GetPerformInfo()
    return mPerform.range or 1
end

function CPerform:PerformTargetType()
    --己方 1，敌方 2
    local mPerform = self:GetPerformInfo()
    return mPerform.target_type or 2
end

function CPerform:PerformTargetStatus()
    --存活或者死亡
    local mPerform = self:GetPerformInfo()
    return mPerform.target_status
end

function CPerform:PerformResume(oAttack)
    local mPerform = self:GetPerformInfo()
    local mEnv = self:FormulaEnv()
    return formula_string(mPerform.resume, mEnv)
end

function CPerform:FormulaEnv()
    local mEnv = {
        level = self:GetLevel(),
    }
    return mEnv
end

function CPerform:GetPerformInfo()
    return share["daobiao"]["perform"][self.m_iPerform]
end

