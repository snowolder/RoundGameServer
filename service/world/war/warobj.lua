local global = require "global"
local share = require "base.share"
local interactive = require "base.interactive"
local baseobj = import(lualib_path("base.baseobj"))

function NewWar(iWar, iRemote, mConfig)
    return CWar:New(iWar, iRemote, mConfig)
end

CWar = {}
CWar.__index = CWar
inherit(CWar, baseobj.CBaseObj)

function CWar:New(iWar, iRemote, mConfig)
    local o = super(CWar).New(self)
    o.m_iWarId = iWar
    o.m_iRemote = iRemote
    o.m_mCamp = {}
    o.m_mPlayers = {}
    o.m_mFunc = {}
    o:Init(mConfig)
    return o
end

function CWar:Release()
    --TODO
    super(CWar).Release(self)
end

function CWar:Init(mConfig)
    self.m_iType = mConfig.type
    self.m_iSubType = mConfig.subtype
    self.m_sName = mConfig.name
    --TODO
end

function CWar:ConfirmRemote()
    local mArgs = {
        war_id = self.m_iWarId,
        type = self.m_iType,
        subtype = self.m_iSubType,
        name = self.m_sName,
    }
    interactive.send(self.m_iRemote, "war", "ConfirmRemote", mArgs)
end

function CWar:PrepareWar(mInfo)
    --准备战场信息，如最大回合数，是否自动战斗等一些列相关信息
    interactive.send(self.m_iRemote, "war", "PrepareWar", {prepare_info=mInfo, war_id=self.m_iWarId})
end

function CWar:PackWarCamp(iCamp, oPlayer)
    return {}
end

function CWar:PrepareCamp(iCamp, mInfo)
    --准备阵营相关信息, 如阵法，友方npc等
    interactive.send(self.m_iRemote, "war", "PrepareCamp", {camp_info=mInfo, war_id=self.m_iWarId, camp_id=iCamp})
end

function CWar:AddPlayer(iCamp, oPlayer, mPlayer, mSummInfo)
    local iPid = oPlayer:GetPid()
    --TODO set war id in player obj
    --TODO sync scene flag to client

    self.m_mPlayers[iPid] = 1
    self.m_mCamp[iPid] = iCamp
    self:GS2CShowWar(oPlayer)
    oPlayer:KeepOnlineForever()

    local mArgs = {
        war_id = self.m_iWarId,
        camp_id = iCamp,
        player = mPlayer,
        summ_info = mSummInfo,
    }
    interactive.send(self.m_iRemote, "war", "AddPlayer", mArgs)
end

function CWar:AddWarriorList(iCamp, lWarrior)
    local mArgs = {
        camp_id = iCamp,
        warrior_list = lWarrior,
        war_id = self.m_iWarId,
    }
    interactive.send(self.m_iRemote, "war", "AddWarriorList", mArgs)
end

function CWar:AfterInitAllWarrior(mInfo)
    --TODO
end

function CWar:WarStart()
    --TODO
end

function CWar:WarEnd(mWarEnd)
    if self.m_bWarEnd then return end

    self.m_bWarEnd = true

    local lFunc = self:GetFunc("pre_war_end")
    for _, func in ipairs(lFunc) do
        safe_call(func, self, mWarEnd)
    end

    local lFunc = self:GetFunc("war_end")
    for _, func in ipairs(lFunc) do
        safe_call(func, self, mWarEnd)
    end

    local lFunc = self:GetFunc("team_war_end")
    for _, func in ipairs(lFunc) do
        safe_call(func, self, mWarEnd)
    end

    interactive.send(self.m_iRemote, "war", "RemoveWar", {war_id=self.m_iWarId})
end

function CWar:AddFunc(sKey, func)
    --TODO 是否加入回掉函数优先级参数
    if not self.m_mFunc[sKey] then
        self.m_mFunc[sKey] = {}
    end
    table.insert(self.m_mFunc[sKey], func)
end

function CWar:GetFunc(sKey, func)
    return self.m_mFunc[sKey] or {}
end

function CWar:GS2CShowWar(oPlayer)
    --TODO 通知客户端, 该协议表示状态切换，同GS2CShowScene
end

function CWar:RemoteLeavePlayer(iPid)
    if not self.m_mPlayers[iPid] then
        return
    end
    self.m_mCamp[iPid] = nil
    self.m_mPlayers[iPid] = nil

    local oPlayer = global.oWorldMgr:GetOnlinePlayerByPid(iPid)
    if oPlayer then
        --TODO del war id in player obj
        --TODO sync scene flag to client
        --TODO reenter scene
        oPlayer:CancelOnlineForever()
    end

    local lFunc = self:GetFunc("leave_war")
    for _, func in ipairs(lFunc) do
        safe_call(func, self, iPid)
    end
end

function CWar:Forward(sMessage, iPid, mData)
    local mArgs = {
        war_id = self.m_iWarId,
        pid = iPid,
        net = mData,
    }
    interactive.send(self.m_iRemote, "war", sMessage, mArgs)
end

