local global = require "global"
local skynet = require "skynet"
local share = require "base.loadshare"
local baseobj = import(lualib_path("base.baseobj"))

CItem = {}
CItem.__index = CItem
CItem.m_sClassType = "item"
CItem.m_sItemType = "base"
inherit(CItem, baseobj.CDataCtrl)

function CItem:New(iSid)
    local o = super(CItem).New(self)
    o.m_iSid = iSid
    o.m_iAmount = 1
    o.m_iItem = global.oItemMgr:DispatchItemId()
    return o
end

function CItem:Release()
    super(CItem).Release(self)
end

function CItem:Save()
    local mSave = {}
    mSave.data = self.m_mData
    mSave.sid = self.m_iSid
    mSave.amount = self.m_iAmount
    return mSave
end

function CItem:Load(m)
    if not m then return end

    self.m_mData = m.data
    self.m_iAmount = m.amount
end

function CItem:SID()
    return self.m_iSid
end

function CItem:ItemType()
    return self.m_sItemType
end

function CItem:GetName()
    local mConfig = self:GetConfig()
    return mConfig.name
end

function CItem:LogName()
    return self:GetName()
end

function CItem:GetAmount()
    return self.m_iAmount
end

function CItem:GetMaxAmount()
    local mConfig = self:GetConfig()
    return mConfig.max_amount or 99
end

function CItem:AddAmount(iAdd)
    self:Dirty()
    local iMaxAmount = self:GetMaxAmount()
    self.m_iAmount = math.max(0, math.min(self.m_iAmount+iAdd, iMaxAmount))
    self:OnAddAmount()
end

function CItem:OnAddAmount()
    if self.m_iAmount <= 0 then
        --TODO remove from container
    end
end

function CItem:GetCostAmount()
    local mConfig = self:GetConfig()
    return mConfig.cost_amount or 1
end

function CItem:ValidUse(oPlayer, iTarget)
    local iCostAmount =self:GetCostAmount()
    if self.m_iAmount < iCostAmount then
        return false
    end
    return true
end

function CItem:Use(oPlayer, iTarget)
    if not self:ValidUse(oPlayer, iTarget) then
        return
    end
    self:TrueUse(oPlayer, iTarget)
end

function CItem:TrueUse(oPlayer, iTarget)
    --TODO
end

function CItem:PackItemNet()
    local mNet = {}
    mNet.sid = self.m_iSid
    mNet.item_id = self.m_iItem
    mNet.amount = self.m_iAmount
    mNet.pos = self.m_iPos
    return mNet
end

function CItem:GetConfig()
    return share["daobiao"]["item"][self.m_iSid]
end
