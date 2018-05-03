local skynet = require "skynet"

skynet.start(function()
    skynet.newservice("share")              --各服务共享数据，可用于策划配表数据
    skynet.newservice("debug_console", 7001)
    skynet.newservice("dictator")           --程序控制后台
    skynet.newservice("gamedb")             --数据存储服务
    skynet.newservice("idsupply")           --id分配中心；玩家id/帮派id等
    skynet.newservice("login")              --登陆服务
    skynet.newservice("world")              --玩法中心
    skynet.exit()
end)
