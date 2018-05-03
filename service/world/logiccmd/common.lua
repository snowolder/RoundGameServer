local skynet = require "skynet"
local protobuf = require "base.protobuf"

function RunTest()
    local mIdField = protobuf.id_field("PlayerProp")
    print("PlayerProp", mIdField)
end
