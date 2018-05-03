local timer = require "base.timer"

local oSaveMgr = nil

CSaveObj = {}
CSaveObj.__index = CSaveObj

function CSaveObj:New(iDispatchId, iDelayMin, func)
    local o = setmetatable({}, self)
    o.m_iSaveId = oSaveMgr:DispatchId()
    o.m_fSaveFunc = func
    o.m_iDelay = math.max(math.min(iDelayMin or 5, 20), 1) * 60 * 1000
    o.m_oTimer = timer.NewTimer()
    return o
end

function CSaveObj:Release()
    self.m_fSaveFuc = nil
    super(CSaveObj).Release(self)
end

function CSaveObj:Init()
    local iSaveId = self.m_iSaveId
    self.m_oTimer:DelTimeCb("ApplySave")
    self.m_oTimer:AddTimeCb("ApplySave", self.m_iDelay, function()
        safe_call(oSaveMgr.CheckSave, oSaveMgr, iSaveId)
    end)
end

function CSaveObj:DoSave()
    if self.m_fSaveFuc then
        safe_call(self.m_fSaveFunc)
    end
end



CSaveMgr = {}
CSaveMgr.__index = CSaveMgr

function CSaveMgr:New()
    local o = setmetatable({}, self)
    o.m_iDispatchId = 0
    o.m_mSaveTable = {}
    o.m_mMergeSave = {}
    o.m_mRepeated = {}
    return o
end

function CSaveMgr:DispatchId()
    self.m_iDispatchId = self.m_iDispatchId + 1
    return self.m_iDispatchId
end

function CSaveMgr:AddSave(obj)
    self.m_mSaveTable[obj.m_iSaveId] = obj
end

function CSaveMgr:DelSave(iSaveId)
    local obj = self.m_mSaveTable[iSaveId]
    if obj then
        obj:Release()
        self.m_mSaveTable[iSaveId] = nil
        self.m_mMergeSave[iSaveId] = nil
    end
end

function CSaveMgr:MergeSave(iSaveId, ...)
    local lSaveList = {iSaveId,}
    for _, obj in ipairs({...}) do
        table.insert(lSaveList, obj.m_iSaveId)
    end
    for _, iSave in ipairs(lSaveList) do
        local lMerge = self.m_mMergeSave[iSave] or {}
        list_combine(lMerge, lSaveList)
        self.m_mMergeSave[iSave] = lMerge
    end
end

function CSaveMgr:SaveAll()
    for iSaveId, oSave in pairs(self.m_mSaveTable) do
        safe_call(oSave.DoSave, oSave)
    end
end

function CSaveMgr:CheckSave(iSaveId)
    local obj = self.m_mSaveTable[iSaveId]
    if not obj then return end

    if self.m_mRepeated[iSaveId] then
        return
    end
    
    safe_call(obj.DoSave, obj)
    self.m_iSaveCnt = self.m_iSaveCnt + 1
    self.m_mRepeated[iSaveId] = 1

    local lMerge = self.m_mMergeSave[iSaveId] or {}
    self.m_mMergeSave[iSaveId] = nil
    for _, iSaveId in ipairs(lMerge) do
        self:CheckSave(iSaveId)
    end

    self.m_iSaveCnt = self.m_iSaveCnt - 1
    if self.m_iSaveCnt <= 0 then
        self.m_mRepeated = {}
    end
end


local M = {}

function M.Init()
    oSaveMgr = CSaveMgr:New()
end

function M.AddSave(iDelayMin, func)
    local iIdx = oSaveMgr:DispatchId()
    local obj = CSaveObj:New(iIdx, iDelayMin, func)
    obj:Init()
    oSaveMgr:AddSave(obj)
    return iIdx
end

function M.DelSave(obj)
    oSaveMgr:DelSave(obj)
end

function M.MergeSave(iSaveId, ...)
    oSaveMgr:MergeSave(iSaveId, ...)
end

return M
