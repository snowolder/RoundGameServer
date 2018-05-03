local M = {}

--M.test = import(service_path("netcmd.test"))
M.item = import(service_path("netcmd.item"))
M.war = import(service_path("netcmd.war"))

function M.Invoke(sMod, sMsg, fd, mData)
    if not M[sMod] then
        skynet.error("uninit net module:"..sMod)
        return
    end

    local func = M[sMod][sMsg]
    if not func then
        skynet.error("uninit net func:"..sMod.."->"..sMsg)
        return
    end

    local oPlayer = global.oWorldMgr:GetOnlinePlayerByFd(fd)
    if oPlayer then
        safe_call(func, oPlayer, mData)
    end
end

return M
