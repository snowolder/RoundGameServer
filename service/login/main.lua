local skynet = require "skynet.manager"
local interactive = require "base.interactive"
local net = require "base.net"
local global = require "global"
local texthandle = require "base.texthandle"
local logiccmd = import(service_path("logiccmd.init"))
local netcmd = import(service_path("netcmd.init"))
local textcmd = import(service_path("textcmd.init"))
local gateobj = import(service_path("gateobj"))


skynet.start(function()
    interactive.dispatch_logic(logiccmd)
    net.dispatch_net(netcmd)
    texthandle.init(textcmd)

    skynet.register(".login")
    
    global.oGateMgr = gateobj:NewGateMgr()
    global.oGateMgr:InitAllGateObj()

    interactive.send(".dictator", "common", "RegisterService", {
        addr = "."..MY_ADDR,
        inst = skynet.self(),
    })
    skynet.error("login service booted")
end)
