local login = {}

login.GS2CHello = function(client, args)
    client:run_cmd("C2GSLoginAccount", {account=client.account, pwd=""})
end

login.GS2CSelectRole = function(client, args)
    if not args.role_list or #args.role_list <= 0 then
        local args = {
            account = client.account,
            name = tostring(os.time()),
            icon = 1,
        }
        client:run_cmd("C2GSCreateRole", args)
    else
        local role = args.role_list[1]
        client:run_cmd("C2GSSelectRole", {account=client.account, pid=role.pid})
    end
end

return login
