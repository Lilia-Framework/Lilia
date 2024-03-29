﻿local function OnPrivilegeRegistered(privilege)
    local permission = privilege.Name
    serverguard.permission:Add(permission)
end

local function RegisterPrivileges()
    if CAMI then
        for _, v in pairs(CAMI.GetPrivileges()) do
            OnPrivilegeRegistered(v)
        end
    end
end

RegisterPrivileges()
