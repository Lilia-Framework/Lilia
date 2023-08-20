--------------------------------------------------------------------------------------------------------
local MODULE = MODULE
--------------------------------------------------------------------------------------------------------
lia.command.add("doorsell", {
    onRun = function(client, arguments)
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        local trace = util.TraceLine(data)
        local entity = trace.Entity

        if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
            if client == entity:GetDTEntity(0) then
                local price = math.Round(entity:getNetVar("price", lia.config.DoorCost) * lia.config.DoorSellRatio)
                entity:removeDoorAccessData()

                MODULE:callOnDoorChildren(entity, function(child)
                    child:removeDoorAccessData()
                end)

                client:getChar():giveMoney(price)
                client:notifyLocalized("dSold", lia.currency.get(price))
                hook.Run("OnPlayerPurchaseDoor", client, entity, false, MODULE.callOnDoorChildren)
                lia.log.add(client, "selldoor")
            else
                client:notifyLocalized("notOwner")
            end
        else
            client:notifyLocalized("dNotValid")
        end
    end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("doorbuy", {
    onRun = function(client, arguments)
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        local trace = util.TraceLine(data)
        local entity = trace.Entity

        if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
            if entity:getNetVar("noSell") or entity:getNetVar("faction") or entity:getNetVar("class") then return client:notifyLocalized("dNotAllowedToOwn") end

            if IsValid(entity:GetDTEntity(0)) then
                client:notifyLocalized("dOwnedBy", entity:GetDTEntity(0):Name())

                return false
            end

            local price = entity:getNetVar("price", lia.config.DoorCost)

            if client:getChar():hasMoney(price) then
                entity:SetDTEntity(0, client)

                entity.liaAccess = {
                    [client] = DOOR_OWNER
                }

                MODULE:callOnDoorChildren(entity, function(child)
                    child:SetDTEntity(0, client)
                end)

                client:getChar():takeMoney(price)
                client:notifyLocalized("dPurchased", lia.currency.get(price))
                hook.Run("OnPlayerPurchaseDoor", client, entity, true, MODULE.callOnDoorChildren)
                lia.log.add(client, "buydoor")
            else
                client:notifyLocalized("canNotAfford")
            end
        else
            client:notifyLocalized("dNotValid")
        end
    end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("doorsetunownable", {
    adminOnly = true,
    syntax = "[string name]",
    onRun = function(client, arguments)
        local entity = client:GetEyeTrace().Entity
        local name = table.concat(arguments, " ")

        if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
            entity:setNetVar("noSell", true)

            if arguments[1] and name:find("%S") then
                entity:setNetVar("name", name)
            end

            MODULE:callOnDoorChildren(entity, function(child)
                child:setNetVar("noSell", true)

                if arguments[1] and name:find("%S") then
                    child:setNetVar("name", name)
                end
            end)

            client:notifyLocalized("dMadeUnownable")
            MODULE:SaveDoorData()
        else
            client:notifyLocalized("dNotValid")
        end
    end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("doorsetownable", {
    adminOnly = true,
    syntax = "[string name]",
    onRun = function(client, arguments)
        local entity = client:GetEyeTrace().Entity
        local name = table.concat(arguments, " ")

        if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
            entity:setNetVar("noSell", nil)

            if arguments[1] and name:find("%S") then
                entity:setNetVar("name", name)
            end

            MODULE:callOnDoorChildren(entity, function(child)
                child:setNetVar("noSell", nil)

                if arguments[1] and name:find("%S") then
                    child:setNetVar("name", name)
                end
            end)

            client:notifyLocalized("dMadeOwnable")
            MODULE:SaveDoorData()
        else
            client:notifyLocalized("dNotValid")
        end
    end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("dooraddfaction", {
    adminOnly = true,
    syntax = "[string faction]",
    onRun = function(client, arguments)
        local entity = client:GetEyeTrace().Entity

        if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
            local faction

            if arguments[1] then
                local name = table.concat(arguments, " ")

                for k, v in pairs(lia.faction.teams) do
                    if lia.util.stringMatches(k, name) or lia.util.stringMatches(L(v.name, client), name) then
                        faction = v
                        break
                    end
                end
            end

            if faction then
                entity.liaFactionID = faction.uniqueID
                local facs = entity:getNetVar("factions", "[]")
                facs = util.JSONToTable(facs)
                facs[faction.index] = true
                local json = util.TableToJSON(facs)
                entity:setNetVar("factions", json)

                MODULE:callOnDoorChildren(entity, function()
                    local facs = entity:getNetVar("factions", "[]")
                    facs = util.JSONToTable(facs)
                    facs[faction.index] = true
                    local json = util.TableToJSON(facs)
                    entity:setNetVar("factions", json)
                end)

                client:notifyLocalized("dSetFaction", L(faction.name, client))
            elseif arguments[1] then
                client:notifyLocalized("invalidFaction")
            else
                entity:setNetVar("factions", "[]")

                MODULE:callOnDoorChildren(entity, function()
                    entity:setNetVar("factions", "[]")
                end)

                client:notifyLocalized("dRemoveFaction")
            end

            MODULE:SaveDoorData()
        end
    end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("doorremovefaction", {
    adminOnly = true,
    syntax = "[string faction]",
    onRun = function(client, arguments)
        local entity = client:GetEyeTrace().Entity

        if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
            local faction

            if arguments[1] then
                local name = table.concat(arguments, " ")

                for k, v in pairs(lia.faction.teams) do
                    if lia.util.stringMatches(k, name) or lia.util.stringMatches(L(v.name, client), name) then
                        faction = v
                        break
                    end
                end
            end

            if faction then
                entity.liaFactionID = nil
                local facs = entity:getNetVar("factions", "[]")
                facs = util.JSONToTable(facs)
                facs[faction.index] = nil
                local json = util.TableToJSON(facs)
                entity:setNetVar("factions", json)

                MODULE:callOnDoorChildren(entity, function()
                    local facs = entity:getNetVar("factions", "[]")
                    facs = util.JSONToTable(facs)
                    facs[faction.index] = nil
                    local json = util.TableToJSON(facs)
                    entity:setNetVar("factions", json)
                end)

                client:notifyLocalized("dRemoveFaction", L(faction.name, client))
            elseif arguments[1] then
                client:notifyLocalized("invalidFaction")
            else
                entity:setNetVar("factions", "[]")

                MODULE:callOnDoorChildren(entity, function()
                    entity:setNetVar("factions", "[]")
                end)

                client:notifyLocalized("dRemoveFaction")
            end

            MODULE:SaveDoorData()
        end
    end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("doorsetdisabled", {
    adminOnly = true,
    syntax = "<bool disabled>",
    onRun = function(client, arguments)
        local entity = client:GetEyeTrace().Entity

        if IsValid(entity) and entity:isDoor() then
            local disabled = util.tobool(arguments[1] or true)
            entity:setNetVar("disabled", disabled)

            MODULE:callOnDoorChildren(entity, function(child)
                child:setNetVar("disabled", disabled)
            end)

            client:notifyLocalized("dSet" .. (disabled and "" or "Not") .. "Disabled")
            MODULE:SaveDoorData()
        else
            client:notifyLocalized("dNotValid")
        end
    end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("doorsettitle", {
    syntax = "<string title>",
    onRun = function(client, arguments)
        local data = {}
        data.start = client:GetShootPos()
        data.endpos = data.start + client:GetAimVector() * 96
        data.filter = client
        local trace = util.TraceLine(data)
        local entity = trace.Entity

        if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
            local name = table.concat(arguments, " ")
            if not name:find("%S") then return client:notifyLocalized("invalidArg", 1) end
            if entity:checkDoorAccess(client, DOOR_TENANT) then
                entity:setNetVar("title", name)
            elseif client:IsAdmin() then
                entity:setNetVar("name", name)

                MODULE:callOnDoorChildren(entity, function(child)
                    child:setNetVar("name", name)
                end)
            else
                client:notifyLocalized("notOwner")
            end
        else
            client:notifyLocalized("dNotValid")
        end
    end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("doorsetparent", {
    adminOnly = true,
    onRun = function(client, arguments)
        local entity = client:GetEyeTrace().Entity

        if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
            client.liaDoorParent = entity
            client:notifyLocalized("dSetParentDoor")
        else
            client:notifyLocalized("dNotValid")
        end
    end
})

lia.command.add("doorsetchild", {
    adminOnly = true,
    onRun = function(client, arguments)
        local entity = client:GetEyeTrace().Entity

        if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
            if client.liaDoorParent == entity then return client:notifyLocalized("dCanNotSetAsChild") end

            if IsValid(client.liaDoorParent) then
                client.liaDoorParent.liaChildren = client.liaDoorParent.liaChildren or {}
                client.liaDoorParent.liaChildren[entity:MapCreationID()] = true
                entity.liaParent = client.liaDoorParent
                client:notifyLocalized("dAddChildDoor")
                MODULE:SaveDoorData()
                MODULE:copyParentDoor(entity)
            else
                client:notifyLocalized("dNoParentDoor")
            end
        else
            client:notifyLocalized("dNotValid")
        end
    end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("doorremovechild", {
    adminOnly = true,
    onRun = function(client, arguments)
        local entity = client:GetEyeTrace().Entity

        if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
            if client.liaDoorParent == entity then
                MODULE:callOnDoorChildren(entity, function(child)
                    child.liaParent = nil
                end)

                entity.liaChildren = nil

                return client:notifyLocalized("dRemoveChildren")
            end

            if IsValid(entity.liaParent) and entity.liaParent.liaChildren then
                entity.liaParent.liaChildren[entity:MapCreationID()] = nil
                entity.liaParent = nil
                client:notifyLocalized("dRemoveChildDoor")
                MODULE:SaveDoorData()
            end
        else
            client:notifyLocalized("dNotValid")
        end
    end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("doorsethidden", {
    adminOnly = true,
    syntax = "<bool hidden>",
    onRun = function(client, arguments)
        local entity = client:GetEyeTrace().Entity

        if IsValid(entity) and entity:isDoor() then
            local hidden = tobool(arguments[1] or true)
            entity:setNetVar("hidden", hidden)

            MODULE:callOnDoorChildren(entity, function(child)
                child:setNetVar("hidden", hidden)
            end)

            client:notifyLocalized("dSet" .. (hidden and "" or "Not") .. "Hidden")
            MODULE:SaveDoorData()
        else
            client:notifyLocalized("dNotValid")
        end
    end
})
--------------------------------------------------------------------------------------------------------
lia.command.add("doorsetclass", {
    adminOnly = true,
    syntax = "[string faction]",
    onRun = function(client, arguments)
        local entity = client:GetEyeTrace().Entity

        if IsValid(entity) and entity:isDoor() and not entity:getNetVar("disabled") then
            local class, classData

            if arguments[1] then
                local name = table.concat(arguments, " ")

                for k, v in pairs(lia.class.list) do
                    if lia.util.stringMatches(v.name, name) or lia.util.stringMatches(L(v.name, client), name) then
                        class, classData = k, v
                        break
                    end
                end
            end

            if class then
                entity.liaClassID = class
                entity:setNetVar("class", class)

                MODULE:callOnDoorChildren(entity, function()
                    entity.liaClassID = class
                    entity:setNetVar("class", class)
                end)

                client:notifyLocalized("dSetClass", L(classData.name, client))
            elseif arguments[1] then
                client:notifyLocalized("invalidClass")
            else
                entity:setNetVar("class", nil)

                MODULE:callOnDoorChildren(entity, function()
                    entity:setNetVar("class", nil)
                end)

                client:notifyLocalized("dRemoveClass")
            end

            MODULE:SaveDoorData()
        end
    end,
    alias = {"jobdoor"}
})
--------------------------------------------------------------------------------------------------------