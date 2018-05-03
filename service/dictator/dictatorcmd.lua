------------------------------
--此模块主要用于实现后台指令
------------------------------

local global = require "global"
local interactive = require "base.interactive"

function update_code(stdin, print_back, file)
    --热更代码
    local dotfile = string.gsub(file, "%/", ".")
    global.oDictatorObj:UpdateCode(dotfile)
end

function uc(stdin, print_back, file)
    update_code(stdin, print_back, file)
end

function update_share(stdin, print_back)
    --更新sharedata 共享数据块
    interactive.send(".share", "common", "UpdateShareData")
end

function inter(stdin, print_back)
    local skynet = require "skynet"
    local interactive = require "base.interactive"
    --interactive.send(".world", "module", "function", "args")
    interactive.send(".gamedb", "testdb", "SaveInfo2TestDb")
end

function runtest(stdin, print_back)
    local skynet = require "skynet"
    local interactive = require "base.interactive"
    interactive.send(".world", "common", "RunTest")
end
