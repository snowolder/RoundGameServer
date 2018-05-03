local global = require "global"

local sTableName = "test"

function SaveInfo2TestDb(...)
    --global.oGameDb:EnsureIndex(sTableName, {pid=1}, {unique=true})
    --global.oGameDb:Insert(sTableName, {pid=11001, base={name="testdata", count=90909}})
    --global.oGameDb:Insert(sTableName, {pid=10002, base={name="testdata", count=90909}})
    --global.oGameDb:Insert(sTableName, {pid=10003, base={name="testdata", count=90909}})
    --global.oGameDb:Update(sTableName, {pid=10003}, {["$set"] = {base={name="testdata", count=90919}}})
    --global.oGameDb:Find(sTableName, {pid=10004}) --need use next func to get useful data
    --global.oGameDb:FindOne(sTableName, {pid=10004})
--    global.oGameDb:Update("account", {account="test2"}, {["$set"] = {
--        roleinfo = {
--            {
--                pid = 10002,
--                name = "pid1",
--                icon = 1,
--            },
--        }
--    }}, true)
end
