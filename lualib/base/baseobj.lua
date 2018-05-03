local skynet = require "skynet"
local timer = require "base.timer"
local savemgr = require "base.savemgr"

CBaseObj = {}
CBaseObj.__index = CBaseObj

function CBaseObj:New()
    local o = setmetatable({}, self)
    o.m_oTimer = timer.NewTimer()
    o.m_bDirty = false
    o.m_mInfo = {}
    return o
end

function CBaseObj:Release()
    self.m_oTimer:Release()
    self.m_oTimer = nil
    self.m_mInfo = {}
end

function CBaseObj:GetInfo(k, default)
    return self.m_mInfo[k] or default
end

function CBaseObj:SetInfo(k, v)
    self.m_mInfo[k] = v
end

function CBaseObj:AddTimeCb(sKey, iDelay, func)
    assert(iDelay > 0)
    self.m_oTimer:AddTimeCb(sKey, iDelay, func)
end

function CBaseObj:DelTimeCb(sKey)
    self.m_oTimer:DelTimeCb(sKey)
end

function CBaseObj:GetTimeCb(sKey)
    return self.m_oTimer:GetTimeCb(sKey)
end


CDataCtrl = {}
CDataCtrl.__index = CDataCtrl
inherit(CDataCtrl, CBaseObj)

function CDataCtrl:New()
    local o = super(CDataCtrl).New(self)
    o.m_mData = {}
    o.m_iSaveId = nil
    return o
end

function CDataCtrl:Release()
    self.m_mData = {}
    if self.m_iSaveId then
        savemgr.DelSave(self.m_iSaveId)
    end
    self.m_iSaveId = nil
    super(CDataCtrl).Release(self)
end

function CDataCtrl:GetData(k, default)
    return self.m_mData[k] or defalut
end

function CDataCtrl:SetData(k, v)
    self:Dirty()
    self.m_mData[k] = v
end

function CDataCtrl:IsDirty()
    return self.m_bDirty
end

function CDataCtrl:Dirty()
    self.m_bDirty = true
end

function CDataCtrl:UnDirty()
    self.m_bDirty = false
end

function CDataCtrl:CheckSaveDb()
    if self:IsDirty() then
        self:SaveDb()
        self:UnDirty()
    end
end

function CDataCtrl:SaveDb()
end

function CDataCtrl:ApplySave(iDelayMin, func)
    assert(not self.m_iSaveId)
    self.m_iSaveId = savemgr.AddSave(iDelayMin, func)
end

function CDataCtrl:MergeSave(...)
    assert(self.m_iSaveId and #{...})
    savemgr.MergeSave(self.m_iSaveId, ...)
end

