local global = require "global"
local interactive = require "base.interactive"

local sTable = "idsupply"

function LoadAllId(mRecord, mData)
    local mCond = {
        id_info = {["$exists"] = true,},
    }
    local mQuery = {
        id_info = 1,
    }
    local mResult = global.oGameDb:FindOne(sTable, mCond, mQuery) or {}
    interactive.respond(mRecord.source, mRecord.session, {data=mResult.id_info})
end

function SaveAllId(mRecord, mData)
    local mCond = {
        id_info = {["$exists"] = true,},
    }
    local mUpdate = {
        ["$set"] = {id_info = mData,},
    }
    local bUpsert = true
    global.oGameDb:Update(sTable, mCond, mUpdate, bUpsert)
end
