local skynet = require "skynet"
local sharedata = require "sharedata"

local M = {}

skynet.init(function()
    --避免每次query创建一个table，一个服务只创建一个table
    --此种写法有一个要求就是需要每个server启动的时候，require "base.share" 进行一次初始化
    local box = sharedata.query("share")
    setmetatable(M, {__index = box})
end, "share")

return M
