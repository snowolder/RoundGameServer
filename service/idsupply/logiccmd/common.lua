local global = require "global"
local interactive = require "base.interactive"

function GenPlayerId(mRecord, mData)
    local oIdMgr = global.oIdMgr
    assert(not oIdMgr:IsLoading())

    local iNewId = oIdMgr:GenPlayerId()
    interactive.respond(mRecord.source, mRecord.session, {id = iNewId})
end
