local skynet = require "skynet"
local global = require "global"
local interactive = require "base.interactive"

local sTable = "account"

function GetRoleList(mRecord, mData)
    local mCond = {
        account = mData.account,
    }
    local mQuery = {
        roleinfo = 1,
    }
    local mResult = global.oGameDb:FindOne(sTable, mCond, mQuery)
    interactive.respond(mRecord.source, mRecord.session, mResult)
end

function SaveRoleList(mRecord, mData)
    local mCond = {
        account = mData.account,
    }
    local mUpdate = {
        ["$set"] = {
            roleinfo = mData.roleinfo,
        },
    }
    local bUpsert = true
    global.oGameDb:Update(sTable, mCond, mUpdate, bUpsert)
end
