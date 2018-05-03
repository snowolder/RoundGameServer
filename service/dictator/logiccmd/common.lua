local global = require "global"

function RegisterService(mRecord, mArgs)
    local iInst = mArgs.inst
    local sAddr = mArgs.addr
    global.oDictatorObj:RegisterService(sAddr, iInst)
end
