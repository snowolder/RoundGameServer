local global = require "global"
local skynet = require "skynet"
local baseobj = import(lualib_path("base.baseobj"))


CTimeCtrl = {}
CTimeCtrl.__index = CTimeCtrl
inherit(CTimeCtrl, baseobj.CDataCtrl)

function CTimeCtrl:New(iPid, mCtrl)
    local o = super(CTimeCtrl).New(self)
    o.m_iPid = iPid
    o.m_mCtrl = mCtrl
    return o
end

function CTimeCtrl:Release()
    for sKey, oTime in pairs(self.m_mCtrl) do
        oTime:Release()
    end
    self.m_mCtrl = {}
end

function CTimeCtrl:SaveDb()
    local mArgs = {
        pid = self.m_iPid,
        name = "timectrl",
        data = self:Save(),
    }
    interactive.send(".gamedb", "playerdb", "SaveOnlineCtrl", mArgs)
end

function CTimeCtrl:Save()
    local mSave = {}
    for sKey, oTime in pairs(self.m_mCtrl) do
        mSave[sKey] = oTime:Save()
    end
    return mSave
end

function CTimeCtrl:Load(m)
    if not m then return end
    
    for sKey, oTime in pairs(self.m_mCtrl) do
        if m[sKey] then
            oTime:Load(m[sKey])
        end
    end
end

function CTimeCtrl:IsDirty()
    for sKey, oTime in pairs(self.m_mCtrl) do
        if oTime:IsDirty() then
            return true
        end
    end
    return false
end

function CTimeCtrl:UnDirty()
    for sKey, oTime in pairs(self.m_mCtrl) do
        oTime:UnDirty()
    end
end

