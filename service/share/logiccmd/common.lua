local skynet = require "skynet"
local sharedata = require "sharedata"

function UpdateShareData(mRecord, mArgs)
    local fp = io.open(skynet.getenv("sharedata_file"))
    local data = fp:read("a")
    fp:close()

    sharedata.update("share", data)
end
