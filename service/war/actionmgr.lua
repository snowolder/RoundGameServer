local skynet = require "skynet"
local global = require "global"
local baseobj = import(lualib_path("base.baseobj"))

function NewActionMgr()
    return CActionMgr:New()
end

CActionMgr = {}
CActionMgr.__index = CActionMgr
inherit(CActionMgr, baseobj.CBaseObj)

function CActionMgr:New()
    local o = super(CActionMgr).New(self)
    return o
end

function CActionMgr:WarSkill(oAttack, mData)
    local iPerform = mData.skill_id
    local iTarget = mData.target

    local oPerform = oAttack:GetPerform(iPerform)
    if not oPerform then return end

    oPerform:Perform(oAttack, iTarget)
end

function CActionMgr:WarNormalAttack(oAttack, mData)
    local oWar = oAttack:GetWarObj()
    assert(oWar)

    local iTarget = mData.target
    local oVictim = oWar:GetWarrior(iTarget)
    if not oVictim or oVictim:IsDead() then
        oVictim = self:RandomNormalTarget()
    end

    self:TryWarNormalAttack(oAttack, oVictim, mArgs)
end

function CActionMgr:TryWarNormalAttack(oAttack, oVictim , mArgs)
    local oWar = oAttack:GetWarObj()
    assert(oWar)

    local bHit = self:CalNormalAttackHit(oAttack, oVictim, mArgs)
    local mNet = {
        war_id = oWar:GetWarId(),
        attack = oAttack:GetWid(),
        victim = oVictim:GetWid(),
        hit = bHit and 1 or 0,
    }
    oWar:BroadCast("GS2CWarNormalAttack", mNet)

    if not bHit then return end

    oWar:AddAnimationTime(1000)
    local iDamage = self:CalNormalAttackDamage(oAttack, oVictim, mArgs)
    self:ReceiveDamage(oVictim, iDamage, {attack = oAttack})

    local lFunc = self:GetFunc("OnAttack")
    for _, func in ipairs(lFunc) do
        safe_call(func, oAttack, oVictim, mArgs)
    end

    local lFunc = self:GetFunc("OnAttacked")
    for _, func in ipairs(lFunc) do
        safe_call(func, oVictim, oAttack, mArgs)
    end

    self:WarriorGoBack(oAttack)
end

function CActionMgr:CalNormalAttackHit(oAttack, oVictim, mArgs)
    return true
end

function CActionMgr:CalNormalAttackDamage(oAttack, oVictim, mArgs)
    return 100
end

function CActionMgr:ReceiveDamage(oVictim, iDamage, mArgs)
    oVictim:SubHp(iDamage, mArgs)
end

function CActionMgr:WarriorGoBack(oWarrior)
    local oWar = oAttack:GetWarObj()
    assert(oWar)

    oWar:AddAnimationTime(300)

    local mNet = {
        war_id = oWar:GetWarId(),
        wid = oWarrior:GetWid(),
    }
    oWar:BroadCast("GS2CWarGoBack", mNet)
end

function CActionMgr:TryPhyAttack(oAttack, oVictim, mArgs)
end

