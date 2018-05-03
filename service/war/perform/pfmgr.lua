local skynet = require "skynet"
local global = require "global"
local share = require "base.share"
local baseobj = import(lualib_path("base.baseobj"))

function NewPerformMgr()
    return CPerformMgr:New()
end

CPerformMgr = {}
CPerformMgr.__index = CPerformMgr
inherit(CPerformMgr, baseobj.CBaseObj)

function CPerformMgr:New()
    local o = super(CPerformMgr).New(self)
    o.m_mPerform = {}
    return o
end

function CPerformMgr:AddPerform(iPerform, oPerform)
    self.m_mPerform[iPerform] = oPerform
end

function CPerformMgr:GetPerform(iPerform)
    return self.m_mPerform[iPerform]
end

