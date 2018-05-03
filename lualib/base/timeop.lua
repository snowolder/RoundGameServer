local skynet = require "skynet"

function get_time(bFloat)
    if bFloat then
        return skynet.time()
    else
        return math.floor(skynet.time())
    end
end

--2018-01-01 00:00:00
local standard_time = 1514736000
function get_dayno(sec)
    sec = sec or get_time()
    return math.floor((sec-standard_time) // (24*3600))
end

function get_weekno(sec)
    sec = sec or get_time()
    return math.floor((sec-standard_time) // (7*24*3600))
end

function get_monthno(sec)
    sec = sec or get_time()
    date = os.date("*t", get_time())
    return date.year*100 + date.month
end
