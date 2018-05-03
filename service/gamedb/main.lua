
local skynet = require "skynet.manager"
local global = require "global"
local interactive = require "base.interactive"
local share = require "base.share"
local gamedb = import(service_path("gamedbobj"))
local logiccmd = import(service_path("logiccmd.init"))


skynet.start(function()
    interactive.dispatch_logic(logiccmd)

    local mConfig = {host="127.0.0.1", port="27017"}
    global.oGameDb = gamedb.NewGameDbObj(mConfig, "game")

    --TODO ensure index
    global.oGameDb:EnsureIndex("account", {account=1}, {unique=true, name="account_index"})
    global.oGameDb:EnsureIndex("player", {pid=1}, {unique=true, name="pid_index"})
    global.oGameDb:EnsureIndex("player", {name=1}, {unique=true, name="name_index"})

    skynet.register(".gamedb")
    interactive.send(".dictator", "common", "RegisterService", {
        addr = "."..MY_ADDR,
        inst = skynet.self(),
    })
    skynet.error("gamedb service booted")
end)
