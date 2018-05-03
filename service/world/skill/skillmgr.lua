local global = require "global"
local share = require "base.share"
local baseobj = import(lualib_path("base.baseobj"))


function NewSkillMgr()
    return CSkillMgr:New()
end

CSkillMgr = {}
CSkillMgr.__index = CSkillMgr
inherit(CSkillMgr, baseobj.CBaseObj)

function CSkillMgr:New()
    local o = super(CSkillMgr).New(self)
    o.m_mSkillCache = {}
    return o
end

function CSkillMgr:GetSkill(iSkill)
    if self.m_mSkillCache[iSkill] then
        return self.m_mSkillCache[iSkill]
    end
    local oSkill = self:CreateSkill(iSkill)
    self.m_mSkillCache[iSkill] = oSkill
    return oSkill
end

function CSkillMgr:CreateSkill(iSkill)
    local mSkill = GetSkillConfig(iSkill)
    assert(mSkill, "unexist skill "..iSkill)

    local sPath = "skill/"..mSkill.belong.."/s"..iSkill
    if file_exists(sPath, ".lua") then
        local oModule = import(service_path(sPath))
        return oModule:New(iSkill)
    else
        local sPath = string.format("skill.%s.%sbase", mSkill.belong, mSkill.belong)
        local oModule = import(service_path(sPath))
        return oModule:New(iSkill)
    end
end

function CSkillMgr:GetSkillConfig(iSkill)
    return share["skill"][iSkill]
end
