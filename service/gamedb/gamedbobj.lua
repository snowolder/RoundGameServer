local skynet = require "skynet"
local mongo = require "mongo"
local baseobj = import(lualib_path("base.baseobj"))

function NewGameDbObj(...)
    return CGameDb:New(...)
end


CGameDb = {}
CGameDb.__index = CGameDb
inherit(CGameDb, baseobj.CBaseObj)

function CGameDb:New(mConfig, sDbName)
    local o = super(CGameDb).New(self)
    o.m_oClient = nil
    o.m_sDbName = sDbName
    o:Init(mConfig)
    return o
end

function CGameDb:Init(mConfig)
    local oClient = mongo.client(mConfig)
    self.m_oClient = oClient
end

function CGameDb:GetDb()
    return self.m_oClient:getDB(self.m_sDbName)
end

function CGameDb:Insert(sTable, mInsert)
    --Insert("player", {account="xterm"})
    local obj = self:GetDb()
    obj[sTable]:safe_insert(mInsert)
    
    local mErr = obj[sTable].database:runCommand("getLastError")
    if mErr and mErr.err and mErr.code then
        print("insert err:" .. sTable, mInsert, mErr.err)
        return false
    end
    return true
end

function CGameDb:Update(sTable, mCond, mUpdate, bUpsert, bMulti)
    --Update("player, {account="xterm"}, {account="xteam", age=17}, true, false)
    local obj = self:GetDb()
    obj[sTable]:update(mCond, mUpdate, bUpsert, bMulti)
    
    local mErr = obj[sTable].database:runCommand("getLastError")
    if mErr and mErr.err and mErr.code then
        print("insert err:" .. sTable, mCond, mUpdate, mErr.err)
    end
end

function CGameDb:Delete(sTable, mCond, bSingle)
    local obj = self:GetDb()
    obj[sTable]:delete(mCond, bSingle)
end

function CGameDb:FindOne(sTable, mQuery, mSelect)
    local obj = self:GetDb()
    local m = obj[sTable]:findOne(mQuery, mSelect)
    return m
end

function CGameDb:Find(sTable, mQuery, mSelect)
    local obj = self:GetDb()
    local m = obj[sTable]:find(mQuery, mSelect)
--    while m:hasNext() do
--        print(m:next())
--    end
    return m
end

function CGameDb:EnsureIndex(sTable, ...)
    --EnsureIndex({index_key=1}, {unique=true,name="name_index"})
    local obj = self:GetDb()
    obj[sTable]:ensureIndex(...)
end

function CGameDb:FindAndModify(mConf)
    local obj = self:GetDb()
    obj:findAndModify(mConf)
end
