local global = require "global"
local share = require "base.share"
local defines = import(lualib_path("base.defines"))
local baseobj = import(service_path("warrior.warrior"))


PropHelper = {}
function PropHelper.wid(oWarrior)
    return oWarrior:GetWid()
end

function PropHelper.grade(oWarrior)
    return oWarrior:GetInfo("grade", 0)
end

function PropHelper.name(oWarrior)
    return oWarrior:GetInfo("name", "")
end

function PropHelper.hp(oWarrior)
    return oWarrior:GetInfo("hp", 0)
end

function PropHelper.max_hp(oWarrior)
    return oWarrior:GetInfo("max_hp", 0)
end

function PropHelper.mp(oWarrior)
    return oWarrior:GetInfo("mp", 0)
end

function PropHelper.max_mp(oWarrior)
    return oWarrior:GetInfo("max_mp", 0)
end


CWarrior = {}
CWarrior.__index = CWarrior
inherit(CWarrior, baseobj.CWarrior)

function CWarrior:New(iWid)
    local o = super(CWarrior).New(self)
    o.m_iType = defines.WARRIOR_TYPE.NPC
    return o
end

function CWarrior:RefreshClientProp(mProp, bAll)
    local mNet = {}
    for sKey, _ in pairs(mProp or PropHelper) do
        if PropHelper[sKey] then
            mNet[sKey] = PropHelper[sKey](self)
        else
            skynet.error("can't find prop " .. sKey)
        end
    end

    mNet = net.Mask("NpcWarrior", mNet)
    self:SendAll("GS2CWarRefreshNpc", {prop = mNet})
end

function CWarrior:SendAll(sMessage, mData)
    local oWar = global.oWarMgr:GetWar(self.m_iWarId)
    if oWar then
        oWar:BroadCast(sMessage, mData)
    end
end

