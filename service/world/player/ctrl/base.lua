local global = require "global"
local skynet = require "skynet"
local baseobj = import(lualib_path("base.baseobj"))


CBaseCtrl = {}
CBaseCtrl.__index = CBaseCtrl
inherit(CBaseCtrl, baseobj.CDataCtrl)

function CBaseCtrl:New(iPid, mRole)
    local o = super(CBaseCtrl).New(self)
    o.m_iPid = iPid
    o.m_iSchool = 0
    o.m_iSex = 0
    o.m_iIcon = 0
    o.m_mModle = {}
    o:Init(mRole)
    return o
end

function CBaseCtrl:Release()
    --
    super(CBaseCtrl).Release(self)
end

function CBaseCtrl:SaveDb()
    local mArgs = {
        pid = self.m_iPid,
        name = "basectrl",
        data = self:Save(),
    }
    interactive.send(".gamedb", "playerdb", "SaveOnlineCtrl", mArgs)
end

function CBaseCtrl:Save()
    local mData = {}
    mData.school = self.m_iSchool
    mData.sex = self.m_iSex
    mData.icon = self.m_iIcon
    mData.model = self.m_mModel
    return mData
end

function CBaseCtrl:Load(m)
    if not m then return end

    self.m_iSchool = m.school
    self.m_iSex = m.sex
    self.m_iIcon = m.icon
    self.m_mModel = m.model
end

function CBaseCtrl:Init(mRole)
    self.m_iSchool = mRole.school
    self.m_iSex = mRole.sex
    self.m_iIcon = mRole.icon
end

function CBaseCtrl:GetSex()
    return self.m_iSex
end

function CBaseCtrl:GetSchool()
    return self.m_iSchool
end

function CBaseCtrl:GetIcon()
    return self.m_iIcon
end

function CBaseCtrl:GetModel()
    return self.m_mModel
end

function CBaseCtrl:OnLogin(oPlayer, bReEnter)
end

