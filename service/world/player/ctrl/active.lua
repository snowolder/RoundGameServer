local global = require "global"
local skynet = require "skynet"
local share = require "base.loadshare"
local baseobj = import(lualib_path("base.baseobj"))


CActiveCtrl = {}
CActiveCtrl.__index = CActiveCtrl
inherit(CActiveCtrl, baseobj.CDataCtrl)

function CActiveCtrl:New(iPid)
    local o = super(CActiveCtrl).New(self)
    o.m_iPid = iPid
    o.m_iExp = 0            --经验
    o.m_iGrade = 0          --等级
    return o
end

function CActiveCtrl:Release()
    --
    super(CActiveCtrl).Release(self)
end

function CActiveCtrl:SaveDb()
    local mArgs = {
        pid = self.m_iPid,
        name = "activectrl",
        data = self:Save(),
    }
    interactive.send(".gamedb", "playerdb", "SaveOnlineCtrl", mArgs)
end

function CActiveCtrl:Save()
    local mData = {}
    mData.exp = self.m_iExp
    mData.grade = self.m_iGrade
    return mData
end

function CActiveCtrl:Load(m)
    if not m then return end
    
    self.m_iExp = m.exp
    self.m_iGrade = m.grade
end

function CActiveCtrl:GetExp()
    return self.m_iExp
end

function CActiveCtrl:GetGrade()
    return self.m_iGrade
end

function CActiveCtrl:RewardExp(iAdd, sReason, mArgs)
    assert(iAdd > 0, string.format("exp %s less than 0, %s", iAdd, sReason))

    local oPlayer = global.oWorldMgr:GetOnlinePlayerByPid(self.m_iPid)   
    --TODO log 
    self.m_iExp = self.m_iExp + iAdd
    oPlayer:PropChange("exp")

    if mArgs.tip ~= false then
        local sMsg = mArgs.tip_content or string.format("获得%d经验", iAdd)
        self:Notify(self.m_iPid, sMsg)
    end

    self:CheckUpgrade()
end

function CActiveCtrl:CheckUpgrade()
    local mNextExpInfo = share["daobiao"]["grade2exp"]
    local iNextExp = mNextExpInfo[self.m_iGrade]
    local iOldGrade = self.m_iGrade
    while self.m_iExp >= iNextExp do
        self.m_iExp = self.m_iExp - iNexExp
        self.m_iGrade = self.m_iGrade + 1
        iNextExp = mNextExpInfo[self.m_iGrade]

        if not iNextExp then break end
    end

    self:OnUpgradeEnd(iOldGrade, self.m_iGrade)

    local oPlayer = global.oWorldMgr:GetOnlinePlayerByPid(self.m_iPid)
    self:PropChange("exp", "grade")
end

function CActiveCtrl:OnUpgradeEnd(iOldGrade, iNewGrade)
    --TODO trigger event
end

function CActiveCtrl:OnLogin(oPlayer, bReEnter)
end

function CActiveCtrl:Notify(iPid, sMsg)
    local oPlayer = global.oWorldMgr:GetOnlinePlayerByPid(iPid)
    if oPlayer then
        oPlayer:Send("GS2CNotify", sMsg)
    end
end


