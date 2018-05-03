local global = require "global"
local skynet = require "skynet"
local share = require "base.loadshare"
local baseobj = import(lualib_path("base.baseobj"))


CItemCtrl = {}
CItemCtrl.__index = CItemCtrl
inherit(CItemCtrl, baseobj.CDataCtrl)

function CItemCtrl:New(iPid)
    local o = super(CItemCtrl).New(self)
    o.m_iPid = iPid
    o.m_mItemList = {}
    return o
end

function CItemCtrl:Release()
    for iPos, oItem in pairs(self.m_mItemList) do
        oItem:Release()
    end
    self.m_mItemList = {}
    super(CItemCtrl).Release(self)
end

function CItemCtrl:SaveDb()
    local mArgs = {
        pid = self.m_iPid,
        name = "itemctrl",
        data = self:Save(),
    }
    interactive.send(".gamedb", "playerdb", "SaveOnlineCtrl", mArgs)
end

function CItemCtrl:Save()
    local mSave = {}
    local mItemData = {}
    for iPos, oItem in pairs(self.m_mItemList) do
        mItemData[tostring(iPos)] = oItem:Save()
    end
    mSave.itemdata = mItemData
    return mSave
end

function CItemCtrl:Load(m)
    if not m then return end
    for sPos, mItem in pairs(m.itemdata or {}) do
        local oItem = global.oItemMgr:LoadItem(mItem)
        self.m_mItemList[tonumber(sPos)] = oItem
    end
end

function CItemCtrl:GetMaxRange()
    return 100
end

function CItemCtrl:ValidAddItemObj(oItem)
    for iPos = 1, self:GetMaxRange() do
        if not self.m_mItemList[iPos] then
            return iPos
        end
    end
end

function CItemCtrl:AddItemObj(oItem, mArgs)
    local iPos = self:ValidAddItemObj(oItem)
    if not iPos then return end

    self.m_mItemList[iPos] = oItem
    oItem.m_iPos = iPos
    self:Dirty()
end

function CItemCtrl:OnLogin(oPlayer, bReEnter)
    local lItemList = {}
    for iPos, oItem in pairs(self.m_mItemList) do
        table.insert(lItemList, oItem:PackItemNet())
    end
    oPlayer:Send("GS2CItemList", {item_list=lItemList})
end

