local skynet = require "skynet"

CTimer = {}
CTimer.__index = CTimer

function CTimer:New()
    local o = setmetatable({}, self)
    o.m_mKey2Index = {}
    o.m_mIndex2Func = {}
    o.m_lReuseIndex = {}
    o.m_iDispatchId = 0
    return o
end

function CTimer:Release()
    self.m_mKey2Index = {}
    self.m_mIndex2Func = {}
    self.m_mReuseIndex = {}
end

function CTimer:DispatchId()
    if #self.m_lReuseIndex > 0 then
        return table.remove(self.m_lReuseIndex, #self.m_lReuseIndex)
    end
    self.m_iDispatchId = self.m_iDispatchId + 1
    return self.m_iDispatchId
end

function CTimer:AddTimeCb(sKey, iDelay, func)
    local iOldCb = self.m_mKey2Index[sKey]
    if iOldCb and self.m_mIndex2Func[iOldCb] then
        skynet.error("can't repeat add timer")
        self.m_mIndex2Func[iOldCb] = nil
        self.m_mKey2Index[sKey] = nil
    end

    local iCb = self:DispatchId()
    self.m_mKey2Index[sKey] = iCb
    self.m_mIndex2Func[iCb] = func
    
    local func = function()
        if self.m_mIndex2Func[iCb] then
            safe_call(self.m_mIndex2Func[iCb])
        end
        self.m_mKey2Index[sKey] = nil
        self.m_mIndex2Func[iCb] = nil
        table.insert(self.m_lReuseIndex, iCb)
    end
    skynet.timeout(iDelay, func)
end

function CTimer:DelTimeCb(sKey)
    local iCb = self.m_mKey2Index[sKey]
    if iCb then
        self.m_mIndex2Func[iCb] = nil
    end
end

function CTimer:GetTimeCb(sKey)
    return self.m_mKey2Index[sKey]
end

local M = {}

M.NewTimer = function()
    return CTimer:New()
end

return M
