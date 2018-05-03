local global = require "global"

--使用道具
function C2GSItemUse(oPlayer, mData)
    local iItem = mData.item_id
    local iTarget = mData.target
    local iAmount = mData.amount
    local oItem = oPlayer.m_oItemCtrl:GetItem(iItem)
    if oItem then
        oItem:Use(oPlayer, iTarget, iAmount)
    end
end

