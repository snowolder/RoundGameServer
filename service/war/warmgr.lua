local global = require "global"
local share = require "base.share"
local baseobj = import(lualib_path("base.baseobj"))
local warobj = import(service_path("warobj"))


function NewWarMgr()
    return CWarMgr:New()
end

CWarMgr = {}
CWarMgr.__index = CWarMgr
inherit(CWarMgr, baseobj.CBaseObj)

function CWarMgr:New()
    local o = super(CWarMgr).New(self)
    o.m_mWars = {}
    return o
end

function CWarMgr:Release()
    for iWar, oWar in pairs(self.m_mWars) do
        oWar:WarEnd(true)
        oWar:Release()
    end
    self.m_mWars = {}
end

function CWarMgr:GetWar(iWar)
    return self.m_mWars[iWar]
end

function CWarMgr:CreateWar(iWar, iType, iSubType, sName)
    --TODO 不同战斗类型使用不同的战斗模块创建战斗对象
    local oWar = warobj.NewWar(iWar, iType, iSubType, sName)
    self.m_mWars[iWar] = oWar
end


