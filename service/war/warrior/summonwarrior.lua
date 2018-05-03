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
    o.m_iPid = nil
    o.m_iType = defines.WARRIOR_TYPE.SUMMON
    return o
end

function CWarrior:Init(mSummon)
    super(CWarrior).Init(self, mSummon)
   
    self.m_iPid = mPlayer.owner
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
    mNet = net.Mask("SummonWarrior", mNet)

    if bAll then
        self:SendAll("GS2CWarRefreshSummon", {prop = mNet})
    else
        self:Send("GS2CWarRefreshSummon", {prop = mNet})
    end
end

function CWarrior:Send(sMessage, mData)
    local oWar = self:GetWarObj()
    if not oWar then return end

    local iWid = oWar:GetWidByPid(self.m_mPid)
    local oWarrior = oWar:GetWarrior(iWid)
    if oWarrior then
        oWarrior:Send(sMessage, mData)
    end
end

function CWarrior:SendAll(sMessage, mData)
    local oWar = global.oWarMgr:GetWar(self.m_iWarId)
    if oWar then
        oWar:BroadCast(sMessage, mData)
    end
end

