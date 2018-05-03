local global = require "global"
local share = require "base.share"
local baseobj = import(lualib_path("base.baseobj"))


CCamp = {}
CCamp.__index = CCamp
inherit(CCamp, baseobj.CBaseObj)

function CCamp:New(iWar, iCamp)
    local o = super(CCamp).New(self)
    o.m_iWarId = iWar
    o.m_iCamp = iCamp
    o.m_mPos2Wid = {}
    o.m_mFunc = {}
    o.m_iStartPos = 1
    o.m_iMaxPos = 15
    return o 
end

function CCamp:Release()
    --
    super(CCamp).Release(self)
end

function CCamp:GetWarId()
    return self.m_iWarId
end

function CCamp:GetWarObj()
    return global.oWarMgr:GetWar(self:GetWarId())
end

function CCamp:DispatchPos(iWid)
    for iPos = self.m_iStartPos, self.m_iMaxPos do
        if not self.m_mPos2Wid[iPos] then
            self.m_mPos2Wid[iPos] = iWid
            return iPos
        end
    end
end

function CCamp:DispatchSummonPos(iPos)
    return iPos + 5
end

function CCamp:AddPlayer(oPlayerWarrior)
    local iWid = oPlayerWarrior:GetWid()
    local iPos = self:DispatchPos(iWid)
    oPlayerWarrior:SetPos(iPos)
    oPlayerWarrior:SetCamp(iCamp)
end

function CCamp:AddSummon(oPlayerWarrior, oSummonWarrior)
    --召唤兽根据玩家站位而站位
    local iPlayerPos = oPlayerWarrior:GetPos()
    local iPos = self:DispatchSummonPos(iPlayerPos)
    self.m_mPos2Wid[iPos] = oSummonWarrior:GetWid()
    oSummonWarrior:SetPos(iPos)
    oSummonWarrior:SetCamp(iCamp)
end

function CCamp:AddWarrior(oWarrior)
    local iWid = oWarrior:GetWid()
    local iPos = self:DispatchPos(iWid)
    oWarrior:SetPos(iPos)
    oWarrior:SetCamp(self.m_iCamp)
end

function CCamp:LeaveWarrior(oWarrior)
    local iPos = oWarrior:GetPos()
    self.m_mPos2Wid[iPos] = nil
end

