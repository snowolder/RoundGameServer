local global = require "global"
local share = require "base.share"
local baseobj = import(lualib_path("base.baseobj"))

CSkill = {}
CSkill.__index = CSkill
inherit(CSkill, baseobj.CBaseObj)

function CSkill:New(iSkill)
    local o = super(CSkill).New(self)
    o.m_iSkill = iSkill
    o.m_iLevel = 1
    o.m_mApply = {}
    o.m_mApplyRatio = {}
    return o
end

function CSkill:Release()
    super(CSkill).Release(self)
end

function CSkill:Save()
    local mSave = {}
    mSave.level = self.m_iLevel
    return mSave
end

function CSkill:Load(m)
    if not m then return end

    self.m_iLevel = m.level
end

function CSkill:Level()
    return self.m_iLevel
end

function CSkill:SetLevel(iLevel)
    self.m_iLevel = iLevel
    self:Dirty()
end

function CSkill:SkillEffect(oPlayer)
end

function CSkill:SkillUnEffect(oPlayer)
end

function CSkill:GetWarPerform()
end

function CSkill:GetSkillInfo()
    return global.oSkillMgr:GetSkillConfig(self.m_iSkill)
end

