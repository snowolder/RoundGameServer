local M = {}

function Require(sPath) 
    local f = loadfile_ex(sPath)
    return f()
end

M.daobiao = Require("daobiao/gamedata/data.lua")

return M
