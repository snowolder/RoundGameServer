
local mCmd = {}

mCmd.testdb = import(service_path("logiccmd.testdb"))
mCmd.accountdb = import(service_path("logiccmd.accountdb"))
mCmd.idsupplydb = import(service_path("logiccmd.idsupplydb"))
mCmd.playerdb = import(service_path("logiccmd.playerdb"))

function Invoke(sModule, sFunc, ...)
    if not mCmd[sModule] then
        print("err: there is not invoke module:"..sModule..", check please")
        return
    end
    if not mCmd[sModule][sFunc] then
        print("err: there is not invoke func:"..sFunc..", check please")
        return
    end

    mCmd[sModule][sFunc](...)
end
