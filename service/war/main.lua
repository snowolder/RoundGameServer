local skynet = require "skynet.manager"
local global = require "global"
local interactive = require "base.interactive"
local share = require "base.share"
local logiccmd = import(service_path("logiccmd.init"))
local warmgr = import(service_path("warmgr"))
local actionmgr = import(service_path("actionmgr"))

skynet.start(function()
    interactive.dispatch_logic(logiccmd)

    global.oWarMgr = warmgr.NewWarMgr()
    global.oActionMgr = actionmgr.NewActionMgr()

    interactive.send(".dictator", "common", "RegisterService", {
        addr = "."..MY_ADDR,
        inst = skynet.self(),
    })
    skynet.error("war service booted")
end)
