local global = require "global"
local share = require "base.share"
local interactive = require "base.interactive"
local baseobj = import(lualib_path("base.baseobj"))
local defines = import(lualib_path("base.defines"))
local campobj = import(service_path("campobj"))
local playerwarrior = import(service_path("warrior.playerwarrior"))
local summonwarrior = import(service_path("warrior.summonwarrior"))
local npcwarrior = import(service_path("warrior.npcwarrior"))


function NewWar(iWar, iType, iSubType, sName)
    return CWar:New(iWar, iType, iSubType, sName)
end

CWar = {}
CWar.__index = CWar
inherit(CWar, baseobj.CBaseObj)

function CWar:New(iWar, iType, iSubType, sName)
    local o = super(CWar).New(self)
    o.m_iWarId = iWar
    o.m_iType = iType
    o.m_iSubType = iSubType
    o.m_sName = sName
    
    o.m_mCamps = {campobj.NewCampObj(iWar, 1), campobj.NewCampObj(iWar, 2)}
    o.m_mPid2Camp = {}          --玩家id对应阵营
    o.m_mPid2Wid = {}           --玩家id对应战斗单位id
    o.m_mWarriors = {}          --所有战斗单位对象
    o.m_iBout = 0               --当前回合信息
    o.m_iDispatchWid = 0        --战斗单位id分配
    o.m_iOperatorTime = 0       --操作时间
    o.m_mBoutCmd = {}           --玩家每回合操作指令
    o.m_iAnimationTime = 0      --招式动作播放时长
    o.m_iWarResult = nil        --战斗结果
    o.m_bWarEnd = false         --战斗结束标记
    return o
end

function CWar:Release()
    for _, oCamp in pairs(self.m_mCamps) do
        oCamp:Release()
    end
    for iWid, oWarrior in pairs(self.m_mWarriors) do
        oWarrior:Release()
    end
    
    super(CWar).Release(self)
end

function CWar:GetWarId()
    return self.m_iWarId
end

function CWar:GetBout()
    return self.m_iBout
end

function CWar:AddBout(i)
    i = i or 1
    self.m_iBout = self.m_iBout + i
end

function CWar:DispatchWid()
    self.m_iDispatchWid = self.m_iDispatchWid + 1
    return self.m_iDispatchWid
end

function CWar:GetCampObj(iCamp)
    assert(iCamp > 0 and iCamp < 3)
    return self.m_mCamps[iCamp]
end

function CWar:GetWarrior(iWid)
    return self.m_mWarriors[iWid]
end

function CWar:GetWidByPid(iPid)
    return self.m_mPid2Wid[iPid]
end

function CWar:PrepareWar(mPrepare)
    self.m_iBoutOut = mPrepare.bout_out
    self.m_iAutoWar = mPrepare.auto_war
end

function CWar:PrepareCamp(iCamp, mCamp)
    --TODO
end

function CWar:AddPlayer(iCamp, mPlayer, mSummInfo)
    local iWid = self:DispatchWid()
    local iPid = mPlayer.pid
    local oPlayerWarrior = playerwarrior.NewWarrior(iWid, self.m_iWarId)
    oPlayerWarrior:Init(mPlayer)
    self.m_mWarrior[iWid] = oPlayerWarrior
    self.m_mPid2Camp[iPid] = iCamp
    self.m_mPid2Wid[iPid] = iWid

    local oCamp = self:GetCampObj(iCamp)
    oCamp:AddPlayer(oPlayerWarrior)

    local iWid = self:DispatchWid()
    local oSummonWarrior = summonwarrior.NewWarrior(iWid, self.m_iWarId)
    oSummonWarrior:Init(mSummInfo)
    self.m_mWarrior[iWid] = oSummonWarrior
    oCamp:AddSummon(oPlayerWarrior, oSummonWarrior)

    --TODO sync to client
end

function CWar:AddWarriorList(iCamp, lWarrior)
    local oCamp = self:GetCampObj(iCamp)
    for _, mWarrior in ipairs(lWarrior) do
        local iWid = self:DispatchWid()
        local oWarrior = npcwarrior.NewWarrior(iWid, self.m_iWarId)
        oWarrior:Init(mWarrior)
        self.m_mWarrior[iWid] = oWarrior
        oCamp:AddWarrior(oWarrior)
    end
    
    --TODO sync to client
end

function CWar:BroadCast(sMessage, mData)
    for iPid, iWid in pairs(self.m_mPid2Wid) do
        local oWarrior = self:GetWarrior(iWid)
        if oWarrior and oWarrior:IsPlayer() then
            oWarrior:Send(sMessage, mData)
        end
    end
end

function CWar:WarStart()
    self:BoutStart()
end

function CWar:BoutStart()
    self:DelTimeCb("BoutStart")
    self:DelTimeCb("BoutEnd")
    self:DelTimeCb("BoutProcess")
    self:DelTimeDb("CheckAutoPerform")
    self:DelTimeCb("WarEnd")

    self:AddBout(1)
    if self:GetBout() == 1 then
        self:OnWarStart()
    end
   
    local iWarId = self:GetWarId() 
    self.m_mBoutCmd = {}
    self.m_iWarStatus = defines.WAR_STATUS.OPERATOR
    self:AddOperatorTime(30)
    local mNet = {
        bout = self:GetBout(),
        war_id = iWarId,
        left_time = self:GetOperatorTime() * 1000,
    }
    self:BroadCast("GS2CBoutStart", mNet)

    safe_call(self.OnBoutStart, self)

    self:AddTimeCb("CheckAutoPerform", 3*1000, function()
        local oWar = global.oWarMgr:GetWar(iWarId)
        if oWar then
            oWar:CheckAutoPerform()
        end
    end)
    self:AddTimeCb("BoutProcess", self:GetOperatorTime(), function()
        local oWar = global.oWarMgr:GetWar(iWarId)
        if oWar then
            oWar:OnAIBoutProcess()
        end
    end)
end

function CWar:OnBoutStart()
    --TODO
end

function CWar:CheckAutoPerform()
    self:DelTimeDb("CheckAutoPerform")
    for iPid, iWid in pairs(self.m_mPid2Wid) do
        local oWarrior = self:GetWarrior(iWid)
        if oWarrior and oWarrior:IsAutoOperator() and not self:GetBoutCmd(iWid) then
            --TODO ai give cmd
            oWarrior:AICommand()
        end
    end
end

function CWar:OnAIBoutProcess()
    self:DelTimeCb("BoutProcess")
    for iWid, oWarrior in pairs(self.m_mWarriors) do
        if not self:GetBoutCmd(iWid) then
            oWarrior:AICommand()
        end
    end

    self:BoutProcess()
end

function CWar:BoutProcess()
    self:DelTimeCb("BoutStart")
    self:DelTimeCb("BoutEnd")
    self:DelTimeCb("BoutProcess")
    self:DelTimeDb("CheckAutoPerform")
    self:DelTimeCb("WarEnd")

    local iWarId = self:GetWarId()
    self.m_iWarStatus = defines.WAR_STATUS.ANIMATION
    safe_call(self.NewBout, self)
    safe_call(self.BoutExecute, self)

    local iCampAlive1 = self.m_mCamps[1]:GetAliveCount()
    local iCampAlive2 = self.m_mCamps[2]:GetAliveCount()
    if iCampAlive1 > 0 and iCampAlive2 > 0 then
        safe_call(self.BoutEnd, self)
    end
    local mNet = {
        war_id = iWarId,
        bout = self:GetBout(),
    }
    self:BroadCast("GS2CWarBoutEnd", mNet)
    
    local iCampAlive1 = self.m_mCamps[1]:GetAliveCount()
    local iCampAlive2 = self.m_mCamps[2]:GetAliveCount()

    local bWarEnd = false
    if iCampAlive1 < 0 then
        self.m_iWarResult = 2
        bWarEnd = true
    elseif iCampAlive2 < 0 then
        self.m_iWarResult = 1
        bWarEnd = true
    elseif self:GetBout() >= self.m_iBoutOut then
        self.m_iWarResult = math.random(1, 2)
        bWarEnd = true
    end
    if bWarEnd then
        self:AddTimeCb("WarEnd", self:GetAnimationTime(), function()
            local oWar = global.oWarMgr:GetWar(iWarId)
            if oWar then
                oWar:WarEnd()
            end
        end)
    else
        self:AddTimeCb("BoutStart", self:GetAnimationTime(), function()
            local oWar = global.oWarMgr:GetWar(iWarId)
            if oWar then
                oWar:BoutStart()
            end
        end)
    end
end

function CWar:NewBout()
    --TODO call hook
end

function CWar:BoutExecute()
    local lDeadWarrior = {}
    local lExecuteList = {}
    local mIgnoreSpeed = {
        defense = 1,
        protect = 1,
    }
    local mExecuteCmd = {}

    for iWid, mCmd in pairs(self.m_mBoutCmd) do
        local oWarrior = self:GetWarrior(iWid)
        if not oWarrior then
            goto continue
        end
        local sCmd = mCmd.cmd
        local mData = mCmd.data
        local mChangeCmd = oWarrior:CheckChangeCmd(mCmd)
        if mChangeCmd then
            sCmd = mChangeCmd.cmd
            mData = mChangeCmd.data
        end

        mExecuteCmd[iWid] = {cmd = sCmd, data = mData}
        if not mIgnoreSpeed[sCmd] then
            table.insert(lExecuteList, {iWid, oWarrior:GetSpeed(sCmd, mData)})
        else
            oWarrior.m_bAction = true
        end
        ::continue::
    end

    local sort_func = function(x, y)
        --保证稳定排序
        if x[2] == y[2] then
            return x:GetWid() > y:GetWid()
        end
        return x[2] < y[2]
    end
    table.sort(lExecuteList, sort_func)

    local oActionMgr = global.oActionMgr
    local iLen = #lExecuteList
    while iLen > 0 do
        local iWid, iSpeed = table.unpack(lExecuteList[iLen])
        local oWarrior = self:GetWarrior(iWid)
        if not oWarrior then
            goto continue
        end
        if not oWarrior:IsAlive() then
            table.insert(lDeadWarrior, {iWid, iSpeed})
        else
            oWarrior.m_bAction = true
            local mCmd = mExecuteCmd[iWid]
            local sCmd = mCmd.cmd
            local mData = mCmd.data
            if sCmd == "skill" then
                safe_call(oActionMgr.WarSkill, oActionMgr, oWarrior, mData)
            elseif sCmd == "normal_attack" then
                safe_call(oActionMgr.WarNormalAttack, oActionMgr, oWarrior, mData)
            end
            table.remove(lExecuteList, iLen)
        end
        ::continue::

        local iCampAlive1 = self.m_mCamps[1]:GetAliveCount()
        local iCampAlive2 = self.m_mCamps[2]:GetAliveCount()
        if iCampAlive1 < 0 or iCampAlive2 < 0 then
            break
        end

        if #lExecuteList > 0 then
            for i = #lExecuteList, 1 do
                local iWid, iSpeed = table.unpack(lExecuteList[i])
                if not self:GetWarrior(iWid) then
                    table.remove(lExecuteList, i)
                end
            end
        else
            for _, lSpeedInfo in pairs(lDeadWarrior) do
                local iWid, iSpeed = table.unpack(lSpeedInfo)
                local oWarrior = self:GetWarrior(iWid)
                if oWarrior and oWarrior:IsAlive() and not oWarrior.m_bAction then
                    table.insert(lExecuteList, {iWid, iSpeed})
                end
            end
        end

        table.sort(lExecuteList, sort_func)
        iLen = #lExecuteList
    end
end

function CWar:WarEnd(bForce)
    if self.m_bWarEnd then return end

    self.m_bWarEnd = true

    local mNet = {
        result = self.m_iWarResult,
        war_id = self.m_iWarId,
    }
    self:BroadCast("GS2CWarEnd", mNet)

    local mWarEnd = self:PackWarEndInfo(bForce)

    for iPid, iWid in pairs(self.m_mPid2Wid) do
        local oWarrior = self:GetWarrior(iWid)
        if oWarrior then
            self:LeavePlayer(oWarrior)
            self:LeaveSummon(oWarrior)
        end
    end

    local mArgs = {
        war_id = self.m_iWarId,
        war_end = mWarEnd,
    }
    interactive.send(".world", "war", "RemoteWarEnd", mArgs)
end

function CWar:LeavePlayer(oWarrior, bEscape)
    --TODO sync to client
    local iPid = oWarrior:GetPid()
    local iWid = oWarrior:GetWid()
    if not self.m_mWarrior[iWid] then
       return
    end

    self.m_mWarrior[iWid] = nil
    self.m_mPid2Wid[iPid] = nil
    self.m_mPid2Camp[iPid] = nil
    local iCamp = oWarrior:GetCamp()
    local oCamp = oWar:GetCampObj(iCamp)
    oCamp:LeaveWarrior(oWarrior)

    local mNet = {
        war_id = self.m_iWarId,
        wid = iWid,
        war_end = self.m_bWarEnd and 1 or 0,
    }
    self:BroadCast("GS2CWarDelWarrior", mNet)

    local mArgs = {
        war_id = self.m_iWarId,
        pid = iPid,
        escape = bEscape,
    }
    interactive.send(".world", "war", "RemoteLeavePlayer", mArgs)
end

function CWar:LeaveSummon(oWarrior)
    --TODO self:BroadCast("GS2CWarDelWarrior", mNet)
end

function CWar:AddOperatorTime(iAdd)
    self.m_iOperatorTime = get_time() + iAdd
end

function CWar:GetOperatorTime()
    return math.max(0, self.m_iOperatorTime - get_time())
end

function CWar:AddAnimationTime(iAdd)
    self.m_iAnimationTime = self.m_iAnimationTime + iAdd
end

function CWar:GetAnimationTime()
    return self.m_iAnimationTime
end

function CWar:AddBoutCmd(iWid, mCmd)
    self.m_mBoutCmd[iWid] = mCmd

    if table_count(self.m_mBoutCmd) >= table_count(self.m_mPid2Wid) then
        self:DelTimeCb("BoutProcess")
        self:BoutProcess()
    end
end

function CWar:GetBoutCmd(iWid)
    return self.m_mBoutCmd[iWid]
end

