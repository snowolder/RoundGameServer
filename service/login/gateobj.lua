local skynet = require "skynet.manager"
local global = require "global"
local net = require "base.net"
local interactive = require "base.interactive"
local baseobj = import(lualib_path("base.baseobj"))
local defines = import(service_path("defines"))


function NewGateMgr(...)
    return CGateMgr:New(...)
end

function NewGateObj(...)
    return CGateObj:New(...)
end

function NewConnection(...)
    return CConnection:New(...)
end

CGateMgr = {}
CGateMgr.__index = CGateMgr
inherit(CGateMgr, baseobj.CBaseObj)

function CGateMgr:New(...)
    local o = super(CGateMgr).New(self)
    o:Init()
    return o
end

function CGateMgr:Init()
    self.m_mGateObj = {}
    self.m_mConnObj = {}
end

function CGateMgr:InitAllGateObj()
    local iPort = skynet.getenv("gate_port")
    local oGate = NewGateObj(iPort)
    self:AddGateObj(oGate)
end

function CGateMgr:AddGateObj(oGate)
    self.m_mGateObj[oGate.m_iAddr] = oGate
end

function CGateMgr:AddConnection(oConn)
    local iFd = oConn:GetFd()
    self.m_mConnObj[iFd] = oConn
    self:OnAddConnection(oConn)
end

function CGateMgr:OnAddConnection(oConn)
    oConn:Forward()
end

function CGateMgr:GetConnection(iFd)
    return self.m_mConnObj[iFd]
end

function CGateMgr:RemoveConnection(iFd)
    local oConn = self.m_mConnObj[iFd]
    if not oConn then return end

    self.m_mConnObj[iFd] = nil
    oConn:OnRemove()
    oConn:Release()
end




CGateObj = {}
CGateObj.__index = CGateObj
inherit(CGateObj, baseobj.CBaseObj)

function CGateObj:New(iPort)
    local o = super(CGateObj).New(self)
    o:Init(iPort)
    return o
end

function CGateObj:Init(iPort)
    self.m_iAddr = skynet.launch("gate", "S", "."..MY_ADDR, iPort, skynet.PTYPE_SOCKET, 5000)
    self.m_iPort = iPort
end


----------------------
CConnection = {}
CConnection.__index = CConnection
inherit(CConnection, baseobj.CBaseObj)

function CConnection:New(iGateAddr, iFd, iPort)
    local o = super(CConnection).New(self)
    o.m_iGateAddr = iGateAddr
    o.m_iFd = iFd
    o.m_iPort = iPort
    o.m_mRoleList = {}
    o.m_sAccount = nil
    o.m_lRoleList = {}
    o.m_iStatus = defines.STATUS_LOGIN.STATUS_INIT
    return o
end

function CConnection:GetGateAddr()
    return self.m_iGateAddr
end

function CConnection:GetFd()
    return self.m_iFd
end

function CConnection:MailAddr()
    return {addr = self.m_iGateAddr, fd = self.m_iFd}
end

function CConnection:Forward()
	skynet.send(self.m_iGateAddr, "text", "forward", self.m_iFd, skynet.address(skynet:self()), skynet.address(self.m_iGateAddr));
    skynet.send(self.m_iGateAddr, "text", "start", self.m_iFd)

    self:Send("GS2CHello", {timestamp=get_time()})
end

function CConnection:Send(sMessage, mData)
    net.Send(self:MailAddr(), sMessage, mData)
end

function CConnection:OnRemove()
    local mArgs = {
        fd = self:GetFd(),
    }
    interactive.send(".world", "login", "KickConnection", mArgs)
end

function CConnection:Release()
    super(CConnection).Release(self)
end


function CConnection:LoginAccount(sAccount, sPwd)
    local iRet = self:ValidLoginByAccount(sAccount, sPwd)
    if iRet ~= defines.LOGIN_CODE.LOGIN_OK then
        self:Send("GS2CLoginError", {errcode = iRet})
        return
    end
    --获取角色列表
    self.m_sAccount = sAccount
    local iFd = self:GetFd()
    self:RemoteGetRoleList(sAccount, function(mRecord, mData)
        local oConn = global.oGateMgr:GetConnection(iFd)
        if oConn then
            oConn:AfterGetRoleList(mRecord, mData)
        end
    end)
end

function CConnection:ValidLoginByAccount(sAccount, sPwd)
    if #trim(sAccount) <= 0 then
        return defines.LOGIN_CODE.LOGIN_ACCOUNT_UNEXIST 
    end
    return defines.LOGIN_CODE.LOGIN_OK
end

function CConnection:RemoteGetRoleList(sAccount, callback)
    interactive.request(".gamedb", "accountdb", "GetRoleList", {account = sAccount},
    function(mRecord, mData)
        callback(mRecord, mData)
    end)
end

function CConnection:AfterGetRoleList(mRecord, mData)
    local lRoleList = {}
    for _, mInfo in pairs(mData.roleinfo or {}) do
        local mRole = {
            pid = mInfo.pid,
            name = mInfo.name,
            icon = mInfo.icon,
        }
        table.insert(lRoleList, mRole)
    end
    self.m_iStatus = defines.STATUS_LOGIN.STATUS_ROLE
    self.m_lRoleList = lRoleList
    self:Send("GS2CSelectRole", {role_list = lRoleList})
end

function CConnection:ValidCreateRole(sAccount, sName, iIcon)
    if self.m_sAccount ~= sAccount then
        return defines.LOGIN_CODE.LOGIN_ACCOUNT_UNEXIST 
    end
    if self.m_iStatus < defines.STATUS_LOGIN.STATUS_ROLE then
        return defines.LOGIN_CODE.LOGIN_UNLOAD_ROLE
    end
    if #self.m_lRolelist >= defines.MAX_ROLE_LIMIT then
        return defines.LOGIN_CODE.LOGIN_ROLE_LIMIT
    end
    return defines.LOGIN_CODE.LOGIN_OK
end

function CConnection:CreateRole(sAccount, sName, iIcon)
    local iRet = self:ValidCreateRole(sAccount, sName, iIcon)
    if iRet ~= 1 then
        self:Send("GS2CLoginError", {errcode = iRet})
        return
    end
    --获取新的玩家id
    local iFd = self:GetFd()
    interactive.request(".idsupply", "common", "GenPlayerId", {},
    function(mRecord, mData)
        local oConn = global.oGateMgr:GetConnection(iFd)
        if oConn then
            oConn:AfterGetPlayerId(sName, iIcon, mData.id)
        end
    end)
end

function CConnection:AfterGetPlayerId(sName, iIcon, iPid)
    --数据库建立了name 和 pid 的唯一索引， 尝试插入检查是否重名重复id
    local mArgs = {
        name = sName,
        pid = iPid,
    }
    local iFd = self:GetFd()
    interactive.request(".gamedb", "playerdb", "InsertPlayerNameAndPid", mArgs,
    function(mRecord, mData)
        local oConn = global.oGateMgr:GetConnection(iFd)
        if oConn then
            oConn:AfterInsertNameAndPid(sName, iIcon, iPid, mData)
        end
    end)
end

function CConnection:AfterInsertNameAndPid(sName, iIcon, iPid, mData)
    if not mData.success then
        self:Send("GS2CLoginError", {errcode = defines.LOGIN_CODE.LOGIN_NAME_DUPLICATE})
        return
    end
    --插入account
    self.m_lRoleList = self.m_lRoleList or {}
    table.insert(self.m_lRoleList, {name=sName, icon=iIcon, pid=iPid})
    local mArgs = {roleinfo = self.m_lRoleList, account=self.m_sAccount}
    interactive.send(".gamedb", "accountdb", "SaveRoleList", mArgs)

    --直接登陆
    self:Login(iPid)
end

function CConnection:ValidSelectRole(sAccount, iPid)
    if self.m_iStatus < defines.STATUS_LOGIN.STATUS_ROLE then
        return defines.LOGIN_CODE.LOGIN_UNLOAD_ROLE
    end
    if sAccount ~= self.m_sAccount then
        return defines.LOGIN_CODE.LOGIN_ACCOUNT_UNEXIST 
    end
    for idx, mRole in ipairs(self.m_lRoleList) do
        if mRole.pid == iPid then
            return defines.LOGIN_CODE.LOGIN_OK
        end
    end
    return defines.LOGIN_CODE.LOGIN_PID_UNEXIST
end

function CConnection:SelectRole(sAccount, iPid)
    local iRet = self:ValidSelectRole(sAccount, iPid)
    if iRet ~= defines.LOGIN_CODE.LOGIN_OK then
        self:Send("GS2CLoginError", {errcode = iRet})
        return
    end
    self:Login(iPid)
end

function CConnection:Login(iPid)
    if not self.m_sAccount then return end

    local mRole = {
        account = self.m_sAccount, 
        addr = self.m_iGateAddr,
        fd = self.m_iFd,
        port = self.m_iPort,
    }
    interactive.send(".world", "login", "LoginPlayer", {pid = iPid, role = mRole})
end

