local global = require "global"
local share = require "base.share"
local baseobj = import(lualib_path("base.baseobj"))
local warobj = import(service_path("war.warobj"))


function NewWarMgr()
    return CWarMgr:New()
end

CWarMgr = {}
CWarMgr.__index = CWarMgr
inherit(CWarMgr, baseobj.CBaseObj)

function CWarMgr:New()
    local o = super(CWarMgr).New(self)
    o.m_mWars = {}
    o.m_iDispatchId = 0
    return o
end

function CWarMgr:Release()
    for iWar, oWar in pairs(self.m_mWars) do
        oWar:Release()
    end
    super(CWarMgr).Release(self)
end

function CWarMgr:DispatchId()
    self.m_iDispatchId = self.m_iDispatchId + 1
    if self.m_iDispatchId > 0x7fffffff then
        self.m_iDispatchId = 1
    end
    return self.m_iDispatchId
end

function CWarMgr:InitRemote(lRemote)
    self.m_lRemote = lRemote
    self.m_iRemoteHash = 0
    self.m_iRemoteSize = #lRemote
end

function CWarMgr:RandomRemote()
    self.m_iRemoteHash = self.m_iRemoteHash + 1

    if self.m_iRemoteHash > self.m_iRemoteSize then
        self.m_iRemoteHash = 1
    end
    return self.m_lRemote[self.m_iRemoteHash]
end

function CWarMgr:CreateWar(mConfig)
    local iWar = self:DispatchId()
    local iRemote = self:RandomRemote()
    local oWar = warobj.NewWar(iWar, iRemote, mConfig)
    oWar:ConfirmRemote()
    self.m_mWars[iWar] = oWar
    return oWar
end

function CWarMgr:RemoveWar(iWar)
    local oWar = self:GetWar(iWar)
    if oWar then
        oWar:Release()
        self.m_mWars[iWar] = nil
    end
end

function CWarMgr:GetWar(iWar)
    return self.m_mWars[iWar]
end

function CWarMgr:PrepareWar(iWar, mPrepare)
    local oWar = self:GetWar(iWar)
    assert(oWar)
    oWar:PrepareWar(mPrepare)
end

function CWarMgr:AfterInitAllWarrior(iWar, mInfo)
    local oWar = self:GetWar(iWar)
    assert(oWar)
    oWar:AfterInitAllWarrior(mInfo)
end

function CWarMgr:WarStart(iWar)
    local oWar = self:GetWar(iWar)
    assert(oWar)
    oWar:WarStart()
end

function CWarMgr:EnterPlayer(iWar, iCamp, oPlayer)
    local oWar = self:GetWar(iWar)
    assert(oWar)

    local mCamp = oWar:PackWarCamp(iCamp, oPlayer)
    oWar:PrepareCamp(iCamp, mCamp)
   
    local mPlayer = nil 
    if oWar.PackPlayerInfo then
        mPlayer = oWar:PackPlayerInfo(oPlayer)
    else
        mPlayer = oPlayer:PackWarInfo(oWar)
    end
   
    --TODO 携带召唤兽
    local mSummInfo = {
        mCurrSumm = nil,            --当前出战
        mKeepSumm = nil,            --宠物栏中
    }
    oWar:AddPlayer(iCamp, oPlayer, mPlayer, mSummInfo)
end

function CWarMgr:AddWarriorList(iWar, iCamp, lWarrior)
    local oWar = self:GetWar(iWar)
    assert(oWar)

    oWar:AddWarriorList(iCamp, lWarrior)
end

function CWarMgr:WarEnd(iWarId, mWarEnd)
    local oWar = self:GetWar(iWar)
    assert(oWar)

    oWar:WarEnd(mWarEnd)
    self:RemoveWar(iWar)
end

function CWarMgr:RemoteLeavePlayer(iWarId, iPid, bEscape)
    local oWar = self:GetWar(iWar)
    if not oWar then return end
   
    oWar:RemoteLeavePlayer(iPid, bEscape) 
end

function CWarMgr:WarSkill(iWarId, iPid, mData)
    local oWar = self:GetWar(iWar)
    if not oWar then return end

    oWar:Forward("C2GSWarSkill", iPid, mData)
end

function CWarMgr:WarNormalAttack(iWarId, iPid, mData)
    local oWar = self:GetWar(iWar)
    if not oWar then return end

    oWar:Forward("C2GSWarNormalAttack", iPid, mData)
end

