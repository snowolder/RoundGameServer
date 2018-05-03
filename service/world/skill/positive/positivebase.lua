----------------------------------
--主动技能，携带战斗中使用的招式--
----------------------------------

local baseobj = import(service_path("skill.skillbase"))

CSkill = {}
CSkill.__index = CSkill
inherit(CSkill, baseobj.CSkill)

function CSkill:GetWarPerform()
    local mSkill = self:GetSkillInfo()
    return mSkill.perform_id
end

