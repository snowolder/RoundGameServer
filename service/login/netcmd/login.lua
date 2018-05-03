
function C2GSLoginAccount(oConn, mData)
    local sAccount = mData.account
    local sPwd = mData.pwd
    oConn:LoginAccount(sAccount, sPwd)
end

function C2GSCreateRole(oConn, mData)
    local sAccount = mData.account
    local sName = mData.name
    local iIcon = mData.icon
    oConn:CreateRole(sAccount, sName, iIcon)
end

function C2GSSelectRole(oConn, mData)
    local sAccount = mData.account
    local iPid = mData.pid
    oConn:SelectRole(sAccount, iPid)
end
