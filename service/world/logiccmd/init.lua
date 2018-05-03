
local mCmd = {}

mCmd.login = import(service_path("logiccmd.login"))
mCmd.common = import(service_path("logiccmd.common"))
mCmd.war = import(service_path("logiccmd.war"))


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
