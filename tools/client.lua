package.path = package.path..";../service/?.lua"..";./lualib/?.lua"
require "tools.robot"
local socket = require "clientsocket"
local argparse = require "base.argparse"

function main(...)
    local parser = argparse("script", "robot")
    parser:option("-s --script", "script file")
    parser:option("-a --account", "account id")

    local script = parser:parse().script
    local account = parser:parse().account

    local robot_obj = robot:new("127.0.0.1", 8102)
    robot.account = account
    robot_obj:fork(robot_obj.run_script, robot_obj, script)

    local co = coroutine.create(function()
        robot_obj:start()
    end)

    while robot_obj.runing do
        coroutine.resume(co)
        socket.usleep(10000)
    end
end

main(...)
