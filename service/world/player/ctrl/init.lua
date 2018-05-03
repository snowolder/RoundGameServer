local skynet = require "skynet"
local global = require "global"

local basectrl = import(service_path("player.ctrl.base"))
local activectrl = import(service_path("player.ctrl.active"))
local itemctrl = import(service_path("player.ctrl.item"))
local timeblock = import(service_path("timeblock"))
local timectrl = import(service_path("player.ctrl.time"))

function NewBaseCtrl(iPid, mRole)
    return basectrl.CBaseCtrl:New(iPid, mRole)
end

function NewActiveCtrl(iPid)
    return activectrl.CActiveCtrl:New(iPid)
end

function NewItemCtrl(iPid)
    return itemctrl.CItemCtrl:New(iPid)
end

function NewTaskCtrl(iPid)
end

function NewSummCtrl(iPid)
end

function NewSkillCtrl(iPid)
end

function NewWieldCtrl(iPid)
end

function NewTodayCtrl(iPid)
    return timeblock.NewToday(iPid)
end

function NewWeekCtrl(iPid)
    return timeblock.NewWeek(iPid)
end

function NewMonthCtrl(iPid)
    return timeblock.NewMonth(iPid)
end

function NewTempCtrl(iPid)
    return timeblock.NewTemp(iPid)
end

function NewTimeCtrl(iPid, mCtrl)
    return timectrl.CTimeCtrl:New(iPid, mCtrl)
end
