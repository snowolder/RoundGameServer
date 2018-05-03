local baseobj = import(lualib_path("base.baseobj"))

function NewToday(id)
    return CToday:New(id)
end

function NewWeek(id)
    return CWeek:New(id)
end

function NewMonth(id)
    return CMonth:New(id)
end

function NewTemp(id)
    return CTemp:New(id)
end

CToday = {}
CToday.__index = CToday
inherit(CToday, baseobj.CBaseObj)

function CToday:New(id)
    local o = super(CToday).New(self)
    o.m_ID = id
    o:Init()
    return o
end

function CToday:Init()
    self.m_mData = {}
    self.m_iTimeNo = self:GetTimeNo()
end

function CToday:GetTimeNo()
    return get_dayno()
end

function CToday:Set(sKey, rVal)
    self.m_mData[sKey] = rVal
    self:Dirty()
end

function CToday:Del(sKey)
    self.m_mData[sKey] = nil
end

function CToday:Add(sKey, iVal)
    local iOld = self:Query(sKey, 0)
    assert(type(iOld) == "number", sKey)
    
    self:Set(sKey, iOld+iVal)
    self:Dirty()
end

function CToday:Query(sKey, rDefault)
    self:Validate()
    return self.m_mData[sKey] or rDefault
end

function CToday:Validate()
    if self:GetTimeNo() ~= self.m_iTimeNo then
        self.m_mData = {}
    end
    self:Dirty()
end

function CToday:Save()
    local mSave = {}
    mSave.data = self.m_mData
    return mSave
end

function CToday:Load(m)
    if not m then return end

    self.m_mData = m.data
end


CWeek = {}
CWeek.__index = CWeek
inherit(CWeek, CToday)

function CWeek:GetTimeNo()
    return get_weekno()
end


CMonth = {}
CMonth.__index = CMonth
inherit(CMonth, CToday)

function CMonth:GetTimeNo()
    return get_monthno()
end


CTemp = {}
CTemp.__index = CTemp
inherit(CTemp, baseobj.CBaseObj)

function CTemp:New(id)
    local o = super(CTemp).New(self)
    o.m_ID = id
    o:Init()
    return o
end

function CTemp:Init()
    self.m_mData = {}
    self.m_mTime = {}
end

function CTemp:GetTimeNo()
    return get_time()
end

--delay 单位(s)
function CTemp:Set(sKey, rVal, iDelay)
    assert(iDelay > 0, sKey)
    self:Validate(sKey)
    self:Dirty()

    if self.m_mData[sKey] then
        self.m_mData[sKey] = rVal
    else
        self.m_mData[sKey] = rVal
        self.m_mTime[sKey] = self:GetTimeNo() + iDelay
    end
end

function CTemp:Reset(sKey, rVal, iDelay)
    assert(iDelay > 0, sKey)
    self.m_mData[sKey] = rVal
    self.m_mTime[sKey] = self:GetTimeNo() + iDelay
    self:Dirty()
end

function CTemp:AddDelay(sKey, iDelay)
    if self.m_mTime[sKey] then
        self.m_mTime[sKey] = self.m_mTime[sKey] + iDelay
    end
    self:Dirty()
end

function CTemp:Delete(sKey)
    self.m_mData[sKey] = nil
    self.m_mTime[sKey] = nil
    self:Dirty()
end

function CTemp:Query(sKey, rDefault)
    self:Validate(sKey)
    return self.m_mData[sKey] or rDefault
end

function CTemp:Validate(sKey)
    if not self.m_mData[sKey] then
        return
    end

    if self:GetTimeNo() < self.m_mTime[sKey] then
        self.m_mData[sKey] = nil
        self.m_mTime[sKey] = nil
    end
    self:Dirty()
end

function CTemp:Save()
    local mSave = {}
    mSave.data = self.m_mData
    mSave.time = self.m_mTime
    return mSave
end

function CTemp:Load(m)
    if not m then return end

    self.m_mData = m.data
    self.m_mTime = m.time
end
