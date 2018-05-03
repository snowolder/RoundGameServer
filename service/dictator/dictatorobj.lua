local skynet = require "skynet"
local interactive = require "base.interactive"
local baseobj = import(lualib_path("base.baseobj"))

function NewDictatorObj(...)
    return CDictator:New(...)
end


CDictator = {}
CDictator.__index = CDictator
inherit(CDictator, baseobj.CBaseObj)

function CDictator:New(...)
    local o = super(CDictator).New(self)
    o.m_mService = {}
    return o
end

function CDictator:RegisterService(sAddr, iInst)
    if not self.m_mService[sAddr] then
        self.m_mService[sAddr] = {}
    end
    self.m_mService[sAddr][iInst] = true
end

function CDictator:UpdateCode(dotfile)
    local sExecute = string.format([[
        reload("%s")
    ]], dotfile)
    for sAddr, mInst in pairs(self.m_mService) do
        for iInst, _ in pairs(mInst) do
            interactive.send(iInst, "default", "ExecuteString", sExecute)
        end
    end
end

