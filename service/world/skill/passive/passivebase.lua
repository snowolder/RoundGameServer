--------------------------
--被动技能，主要影响属性--
--------------------------

local baseobj = import(service_path("skill.skillbase"))

CSkill = {}
CSkill.__index = CSkill
inherit(CSkill, baseobj.CSkill)

function CSkill:SkillEffect(oPlayer)
    local mRefresh = self:SkillUnEffect(oPlayer)
    local mEnv = {lv = self:Level()}

    local mSkill = self:GetSkillInfo()
    local mApply = formula_string(mSkill.skill_effect, mEnv)
    for sAttr, iVal in pairs(mApply) do
        oPlayer.m_oSkillAttr:AddApplyRatio(self.m_iSkill, sAttr, iVal)
        self.m_mApply[sAttr] = (self.m_mApply[sAttr] or 0) + iVal
        mRefresh[sAttr] = 1
    end

    local mApplyRatio = formula_string(mSkill.skill_effect_ratio, mEnv)
    for sAttr, iVal in pairs(mApplyRatio) do
        oPlayer.m_oSkillAttr:AddApplyRatio(self.m_iSkill, sAttr, iVal)
        self.m_mApplyRatio[sAttr] = (self.m_mApplyRatio[sAttr] or 0) + iVal
        mRefresh[sAttr] = 1
    end

    return mRefresh
end

function CSkill:SkillUnEffect(oPlayer)
    local mRefresh = {}
    for sAttr, iVal in pairs(self.m_mApply) do
        oPlayer.m_oSkillAttr:AddApply(self.m_iSkill, sAttr, -iVal)
        mRefresh[sAttr] = 1
    end
    for sAttr, iVal in pairs(self.m_mApplyRatio) do
        oPlayer.m_oSkillAttr:AddApplyRatio(self.m_iSkill, sAttr, -iVal)
        mRefresh[sAttr] = 1
    end
    
    return mRefresh
end

