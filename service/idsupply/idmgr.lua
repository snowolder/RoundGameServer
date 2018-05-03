local global = require "global"
local interactive = require "base.interactive"
local baseobj = import(lualib_path("base.baseobj"))

function NewIdMgr(...)
    return CIdMgr:New(...)
end

CIdMgr = {}
CIdMgr.__index = CIdMgr
inherit(CIdMgr, baseobj.CBaseObj)

function CIdMgr:New()
    local o = super(CIdMgr).New(self)
    o.m_iPlayerId = 1000
    o.m_bLoading = true
    return o
end

function CIdMgr:SaveDb()
    assert(not self.m_bLoading)
    local mData = {
        player_id = self.m_iPlayerId
    }
    interactive.send(".gamedb", "idsupplydb", "SaveAllId", mData)
end

function CIdMgr:LoadDb()
    assert(self.m_bLoading)
    interactive.request(".gamedb", "idsupplydb", "LoadAllId", {},
    function(mRecord, mData)
        global.oIdMgr:Load(mData.data)
        global.oIdMgr:LoadFinish()
    end)
end

function CIdMgr:Load(mData)
    if not mData then return end
    self.m_iPlayerId = mData.player_id or self.m_iPlayerId
end

function CIdMgr:LoadFinish()
    self.m_bLoading = false
end

function CIdMgr:IsLoading()
    return self.m_bLoading
end

function CIdMgr:GenPlayerId()
    self.m_iPlayerId = self.m_iPlayerId + 1
    self:SaveDb()
    return self.m_iPlayerId
end

