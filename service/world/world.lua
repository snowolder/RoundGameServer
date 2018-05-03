local skynet = require "skynet"
local global = require "global"
local interactive = require "base.interactive"
local baseobj = import(lualib_path("base.baseobj"))
local connection = import(service_path("connection"))
local player = import(service_path("player.playerobj"))

function NewWorldMgr(...)
    return CWorldMgr:New(...)
end

CWorldMgr = {}
CWorldMgr.__index = CWorldMgr
inherit(CWorldMgr, baseobj.CBaseObj)

function CWorldMgr:New(...)
    local o = super(CWorldMgr).New(self)
    o.m_mOnlinePlayers = {}     --已经登陆的玩家
    o.m_mLoginPlayers = {}      --登陆中的玩家
    o.m_iServerGrade = 0        --服务器等级 
    o.m_iOpenDays = 0           --服务器开放天数
    o.m_mPlayerPropChange = {}  --帧末刷新玩家属性
    return o
end

function CWorldMgr:GetOnlinePlayerByPid(iPid)
    return self.m_mOnlinePlayers[iPid]
end

function CWorldMgr:GetOnlinePlayerByFd(iFd)
    local iPid = global.oConnMgr:GetPidByFd(iFd)
    if not iPid then return end
    return self:GetOnlinePlayerByPid(iPid)
end

function CWorldMgr:LoginPlayer(iPid, mRole)
    local oPlayer = self:GetOnlinePlayerByPid(iPid)
    if oPlayer then
        local oConn = self:CreateConnection(mRole)
        global.oConnMgr:AddConnection(iPid, oConn)
        oPlayer:OnLogin(false)
    else
        local oConn = self:CreateConnection(mRole)
        global.oConnMgr:AddConnection(iPid, oConn)

        local oPlayer = self:CreatePlayer(iPid, mRole)
        self.m_mLoginPlayers[iPid] = oPlayer
       
        interactive.request(".gamedb", "playerdb", "LoadOnlineCtrl", {pid = iPid},
        function(mRecord, mData)
            global.oWorldMgr:LoadPlayerCb(iPid, mData)
        end)
    end
end

function CWorldMgr:CreateConnection(mRole)
    return connection.NewConnection(mRole)
end

function CWorldMgr:CreatePlayer(iPid, mRole)
    local oPlayer = player.NewPlayerObj(iPid, mRole)
    return oPlayer
end

function CWorldMgr:LoadPlayerCb(iPid, mData)
    local oPlayer = self.m_mLoginPlayers[iPid]
    assert(oPlayer)

    if not mData then return end

    local lCtrl2LoadCb = {
        {"m_oBaseCtrl", "basectrl",},
        {"m_oActiveCtrl", "activectrl",},
        {"m_oItemCtrl", "itemctrl",},
        {"m_oTimeCtrl", "timectrl",},
--        {"m_oTaskCtrl", "taskctrl",},
--        {"m_oSummCtrl", "summctrl",},
--        {"m_oSkillCtrl", "skillctrl",},
--        {"m_oWieldCtrl", "wieldctrl",},
    }

    for _, mInfo in ipairs(lCtrl2LoadCb) do
        local sCtrl, sKey = table.unpack(mInfo)
        safe_call(oPlayer[sCtrl].Load, oPlayer[sCtrl], mData["data"][sKey])
    end
    oPlayer:SetName(mData["data"]["name"])

    self:LoadPlayerFinish(iPid)
end

function CWorldMgr:LoadOfflineBlock(iPid, iIdx)
    --TODO
end

function CWorldMgr:LoadPlayerFinish(iPid)
    local oPlayer = self.m_mLoginPlayers[iPid]
    self.m_mOnlinePlayers[iPid] = oPlayer
    self.m_mLoginPlayers[iPid] = nil
    oPlayer:LoadFinish()
    oPlayer:OnLogin(true)
end

function CWorldMgr:SetPlayerPropChange(iPid, sProp)
    if not self.m_mPlayerPropChange[iPid] then
        self.m_mPlayerPropChange[iPid] = {}
    end
    self.m_mPlayerPropChange[iPid][sProp] = 1
end

function CWorldMgr:DoPlayerPropChange()
    local mPlayerProp = self.m_mPlayerPropChange
    self.m_mPlayerPropChange = {}

    for iPid, mProp in pairs(mPlayerProp) do
        local oPlayer = self:GetOnlinePlayerByPid(iPid)
        if oPlayer and next(mProp) then
            safe_call(oPlayer.RefreshClientProp, oPlayer, mProp)
        end
    end
end

