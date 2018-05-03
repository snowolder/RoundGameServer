local skynet = require "skynet"
local manager = require "skynet.manager"
local sharedata = require "sharedata"
local interactive = require "base.interactive"
local logiccmd = import(service_path("logiccmd.init"))

skynet.start(function()
    interactive.dispatch_logic(logiccmd)

    local fp = io.open(skynet.getenv("sharedata_file"))
    local data = fp:read("a")
    fp:close()
    sharedata.new("share", data)

    manager.register ".share"
    skynet.error("share service booted")
end)
