local global = require "global"
local skynet = require "skynet"
local share = require "base.loadshare"
local itembase = import(service_path("item.itembase"))

CItem = {}
CItem.__index = CItem
CItem.m_sClassType = "item"
CItem.m_sItemType = "other"
inherit(CItem, itembase.CItem)

function CItem:TrueUse(oPlayer, iTarget)
    local iCost = self:GetCostAmount()
    local sLogName = self:LogName()
    self:AddAmount(-iCost)
    local iAddExp = iCost * 1000
    oPlayer.m_oActiveCtrl:RewardExp(iAddExp, sLogName)
end
