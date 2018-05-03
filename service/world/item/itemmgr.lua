local global = require "global"
local skynet = require "skynet"
local share = require "base.loadshare"
local baseobj = import(lualib_path("base.baseobj"))

function NewItemMgr()
    return CItemMgr:New()
end


CItemMgr = {}
CItemMgr.__index = CItemMgr
inherit(CItemMgr, baseobj.CBaseObj)

function CItemMgr:New()
    local o = super(CItemMgr).New(self)
    o.m_iDispatchId = 0
    o.m_mCacheItem = {}
    return o
end

function CItemMgr:DispatchItemId()
    self.m_iDispatchId = self.m_iDispatchId + 1
    return self.m_iDispatchId
end

function CItemMgr:GetItem(iSid)
    if not self.m_mCacheItem[iSid] then
        self.m_mCacheItem[iSid] = self:CreateItem(iSid)
    end
    return self.m_mCacheItem[iSid]
end

function CItemMgr:CreateItem(iSid)
    local mItem = self:GetConfigBySid(iSid)
    assert(mItem, "unexist item:" .. iSid)
    
    local sPath = "item/"..mItem.belong.."/i"..iSid
    if file_exists(sPath, ".lua") then
        local oModule = import(service_path(sPath))
        return oModule:New(iSid)
    else
        local sPath = string.format("item.%s.%sbase", mItem.belong, mItem.belong)
        local oModule = import(service_path(sPath))
        return oModule:New(iSid)
    end
end

function CItemMgr:LoadItem(mItem)
    local oItem = self:CreateItem(mItem.sid)
    oItem:Load(mItem)
    return oItem
end

function CItemMgr:GetConfigBySid(iSid)
    return share["daobiao"]["item"][iSid]
end
