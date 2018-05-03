local global = require "global"
local interactive = require "base.interactive"

local sTable = "player"

function InsertPlayerNameAndPid(mRecord, mData)
    local mInsert = {
        name = mData.name,
        pid = mData.pid,
    }
    local bSuccess = global.oGameDb:Insert(sTable, mInsert)
    interactive.respond(mRecord.source, mRecord.session, {success=bSuccess})
end

--玩家在线时候才能加载这些模块
function LoadOnlineCtrl(mRecord, mData)
    local mCond = {
        pid = mData.pid,
    }
    local mQuery = {
        basectrl = 1,
        activectrl = 1,
        itemctrl = 1,
        taskctrl = 1,
        summctrl = 1,
        skillctrl = 1,
        wieldctrl = 1,
        timectrl = 1,
        name = 1,
    }
    local m = global.oGameDb:FindOne(sTable, mCond, mQuery)
    interactive.respond(mRecord.source, mRecord.session, {data=m})
end

function SaveOnlineCtrl(mRecord, mData)
    local mCond = {
        pid = mData.pid,
    }
    local mUpdate = {
        ["$set"] = {
            [mData.name] = mData.data,
        }
    }
    local bUpsert = true
    global.oGameDb:Update(sTable, mCond, mUpdate, bUpsert)
end

