local skynet = require "skynet"

local M = {}
local textcmd = {}

function M.init(m)
    textcmd = m
    
    skynet.register_protocol(
        {
            name = "text",
            id = skynet.PTYPE_TEXT,
            pack = function(...)
                return table.concat({...}, " ")
            end,
            unpack = function(...) return ... end,
        }
    )
    skynet.dispatch("text", function(...)
        textcmd.Invoke(...)
    end)
end

return M
