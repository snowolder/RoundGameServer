local skynet = require "skynet"
local global = require "global"
local baseobj = import(lualib_path("base.baseobj"))

function NewNpcMgr()
    return CNpcMgr:New()
end

CNpcMgr = {}
CNpcMgr.__index = CNpcMgr
inherit(CNpcMgr, baseobj.CBaseObj)

function CNpcMgr:New()
    local o = super(CNpcMgr).New(self)
    o.m_iDispatchId = 1
    return o
end

