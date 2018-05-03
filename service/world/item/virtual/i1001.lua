local global = require "global"
local skynet = require "skynet"
local share = require "base.loadshare"
local itembase = import(service_path("item.virtual.virtualbase"))

CItem = {}
CItem.__index = CItem
inherit(CItem, itembase.CItem)

function CItem:Reward(oPlayer)
    local iCost = self:GetCostAmount()
    local sLogName = self:LogName()
    self:AddAmount(-iCost)

    local iVal = self:GetData("value") * iCost
    if iVal <= 0 then return end
    
    --oPlayer:RewardGold(iVal, sLogName)
end
