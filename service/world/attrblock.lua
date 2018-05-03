local global = require "global"
local baseobj = import(lualib_path("base.baseobj"))


CAttrBlock = {}
CAttrBlock.__index = CAttrBlock
inherit(CAttrBlock, baseobj.CBaseObj)

function CAttrBlock:New(id)
    local o = super(CAttrBlock).New(self)
    o.m_ID = id
    o.m_mApply = {}
    o.m_mApplyRatio = {}
    return o
end

function CAttrBlock:AddApply(iSrc, sKey, iVal)
    local mApply = self.m_mApply[sKey] or {}
    local iNowVal = (mApply[iSrc] or 0) + iVal
    mApply[iSrc] = iNowVal
    self.m_mApply[sKey] = mApply
end

function CAttrBlock:GetApply(sKey)
    local mApply = self.m_mApply[sKey] or {}
    local iTotal = 0
    for iSrc, iVal in pairs(mApply) do
        iTotal = iTotal + iVal
    end
    return iTotal
end

function CAttrBlock:DelApply(iSrc, sKey)
    local mApply = self.m_mApply[sKey] or {}
    local iSrcVal = mApply[iSrc] or 0
    mApply[iSrc] = nil
    return iSrcVal
end

function CAttrBlock:AddApplyRatio(iSrc, sKey, iVal)
    local mApplyRatio = self.m_mApplyRatio[sKey] or {}
    local iNowVal = (mApplyRatio[iSrc] or 0) + iVal
    mApplyRatio[iSrc] = iNowVal
    self.m_mApplyRatio[sKey] = mApplyRatio
end

function CAttrBlock:GetApplyRatio(sKey)
    local mApplyRatio = self.m_mApplyRatio[sKey]
    local iTotal = 0
    for iSrc, iVal in pairs(mApplyRatio) do
        iTotal = iTotal + iVal
    end
    return iTotal
end

function CAttrBlock:DelApplyRatio(iSrc, sKey)
    local mApplyRatio = self.m_mApplyRatio[sKey]
    local iSrcVal = mApplyRatio[iSrc] or 0
    mApplyRatio[iSrc] = nil
    return iSrcVal
end

function CAttrBlock:ClearAllBySrc(iSrc)
    for sKey, mApply in pairs(self.m_mApply) do
        mApply[iSrc] = nil
    end
    for sKey, mApplyRatio in pairs(self.m_mApplyRatio) do
        mApplyRatio[iSrc] = nil
    end
end

