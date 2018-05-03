local global = require "global"
local skynet = require "skynet"
local share = require "base.loadshare"
local itembase = import(service_path("item.itembase"))

CItem = {}
CItem.__index = CItem
CItem.m_sClassType = "item"
CItem.m_sItemType = "virtual"
inherit(CItem, itembase.CItem)

function CItem:Reward(oPlayer)
    --
end
