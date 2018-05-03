local skynet = require "skynet"
local net = require "base.net"
local interactive = require "base.interactive"
local baseobj = import(lualib_path("base.baseobj"))

function NewConnection(...)
    return CConnection:New(...)
end

function NewConnectionMgr(...)
    return CConnectionMgr:New(...)
end


CConnection = {}
CConnection.__index = CConnection
inherit(CConnection, baseobj.CBaseObj)

function CConnection:New(mRole)
    local o = super(CConnection).New(self)
    o.m_iGateAddr = mRole.addr
    o.m_iFd = mRole.fd
    o.m_iPort = mRole.port
    return o
end

function CConnection:ResetConn(mRole)
    self.m_iGateAddr = mRole.addr or self.m_iGateAddr
    self.m_iFd = mRole.fd or self.m_iFd
    self.m_iPort = mRole.port or self.m_iPort
end

function CConnection:MailAddr()
    return {addr = self.m_iGateAddr, fd = self.m_iFd}
end

--把world服设置为连接的代理，在world服处理协议包
function CConnection:Forward()
	skynet.send(self.m_iGateAddr, "text", "forward", self.m_iFd, skynet.address(skynet:self()), skynet.address(self.m_iGateAddr));
end

function CConnection:Send(sMessage, mData)
    net.Send(self:MailAddr(), sMessage, mData)
end

function CConnection:ReplaceByNewConn()
    --TODO notify 
    --self:Send("GS2CNotify", {msg="您的账号在别处登陆"})
    local mArgs = {
        addr = self.m_iGateAddr,
        fd = self.m_iFd,
        port = self.m_iPort,
    }
    interactive.send(".login", "common", "KickConnection", mArgs)
end


CConnectionMgr = {}
CConnectionMgr.__index = CConnectionMgr
inherit(CConnectionMgr, baseobj.CBaseObj)

function CConnectionMgr:New()
    local o = super(CConnectionMgr).New(self)
    o.m_mConnections = {}
    o.m_mPid2Fd = {}
    o.m_mFd2Pid = {}
    return o
end

function CConnectionMgr:AddConnection(iPid, oConn)
    local oOldConn = self:GetConnectionByPid(iPid)
    if oOldConn then
        local iFd = oOldConn.m_iFd
        oOldConn:ReplaceByNewConn()
        self:DelConnectionByFd(iFd)
    end
    local iFd = oConn.m_iFd
    self.m_mPid2Fd[iPid] = iFd
    self.m_mFd2Pid[iFd] = iPid
    self.m_mConnections[iFd] = oConn
    oConn:Forward()
end

function CConnectionMgr:DelConnectionByFd(iFd)
    local oConn = self:GetConnectionByFd(iFd)
    if oConn then
        local iPid = self.m_mFd2Pid[iFd]
        self.m_mFd2Pid[iFd] = nil
        if iPid then
            self.m_mPid2Fd[iPid] = nil
        end
        self.m_mConnections[iFd] = nil
        oConn:Release()
    end
end

function CConnectionMgr:GetConnectionByFd(iFd)
    return self.m_mConnections[iFd]
end

function CConnectionMgr:GetPidByFd(iFd)
    return self.m_mFd2Pid[iFd]
end

function CConnectionMgr:GetConnectionByPid(iPid)
    local iFd = self.m_mPid2Fd[iPid]
    if iFd then
        return self.m_mConnections[iFd]
    end
end

