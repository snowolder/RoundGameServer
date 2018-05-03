local global = require "global"
local skynet = require "skynet"
local share = require "base.loadshare"
local baseobj = import(lualib_path("base.baseobj"))


CSkillCtrl = {}
CSkillCtrl.__index = CSkillCtrl
inherit(CSkillCtrl, baseobj.CDataCtrl)

function CSkillCtrl:New(iPid)
    local o = super(CSkillCtrl).New(self)
    o.m_iPid = iPid
    o.m_mPassiveSkill = {}      --被动技能
    o.m_mPositiveSkill = {}     --主动技能
    return o
end

function CSkillCtrl:Release()
    for iSkill, oSkill in pairs(self.m_mPassiveSkill) do
        oSkill:Release()
    end
    self.m_mPassiveSkill = {}
    for iSkill, oSkill in pairs(self.m_mPositiveSkill) do
        oSkill:Release()
    end
    self.m_mPositiveSkill = {}

    super(CSkillCtrl).Release(self)
end

function CSkillCtrl:SaveDb()
    local mArgs = {
        pid = self.m_iPid,
        name = "skillctrl",
        data = self:Save(),
    }
    interactive.send(".gamedb", "playerdb", "SaveOnlineCtrl", mArgs)
end

function CSkillCtrl:Save()
    local mSave = {}
    local mPositive = {}
    for iSkill, oSkill in pairs(self.m_mPositiveSkill) do
        mPositive[tostring(iSkill)] = oSkill:Save()
    end
    mSave.positive = mPositive
    
    local mPassive = {}
    for iSkill, oSkill in pairs(self.m_mPassiveSkill) do
        mPassive[tostring(iSkill)] = oSkill:Save()
    end
    mSave.passive = mPassive
    return mSave
end

function CSkillCtrl:Load(m)
    if not m then return end

    for sSkill, mSkill in pairs(m.positive or {}) do
        local iSkill = tonumber(sSkill)
        local oSkill = global.oSkillMgr:CreateSkill(iSkill)
        oSkill:Load(mSkill)
        self.m_mPositiveSkill[iSkill] = oSkill
    end

    for sSkill, mSkill in pairs(m.passive or {}) do
        local iSkill = tonumber(sSkill)
        local oSkill = global.oSkillMgr:CreateSkill(iSkill)
        oSkill:Load(mSkill)
        self.m_mPassiveSkill[iSkill] = oSkill
    end
end


