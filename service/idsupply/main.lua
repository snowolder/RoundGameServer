local skynet = require "skynet.manager"
local interactive = require "base.interactive"
local net = require "base.net"
local global = require "global"
local logiccmd = import(service_path("logiccmd.init"))
local idmgr = import(service_path("idmgr"))

skynet.start(function()
    interactive.dispatch_logic(logiccmd)

    skynet.register(".idsupply")
   
    global.oIdMgr = idmgr.NewIdMgr()
    global.oIdMgr:LoadDb()

    interactive.send(".dictator", "common", "RegisterService", {
        addr = "."..MY_ADDR,
        inst = skynet.self(),
    })
    skynet.error("idsupply service booted")
end)
