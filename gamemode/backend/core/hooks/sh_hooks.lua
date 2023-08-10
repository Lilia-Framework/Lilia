--------------------------------------------------------------------------------------------------------
local getModelClass = lia.anim.getModelClass
local IsValid = IsValid
local string = string
local type = type
local playeranimtype = lia.anim.PlayerHoldtypeTranslator
local defaultanimtype = lia.anim.HoldtypeTranslator
--------------------------------------------------------------------------------------------------------
function GM:TranslateActivity(client, act)
    local model = string.lower(client.GetModel(client))
    local class = getModelClass(model) or "player"
    local weapon = client.GetActiveWeapon(client)

    if class == "player" then
        if not lia.config.WepAlwaysRaised and IsValid(weapon) and (client.isWepRaised and not client.isWepRaised(client)) and client:OnGround() then
            if string.find(model, "zombie") then
                local tree = lia.anim.zombie

                if string.find(model, "fast") then
                    tree = lia.anim.fastZombie
                end

                if tree[act] then return tree[act] end
            end

            local holdType = IsValid(weapon) and (weapon.HoldType or weapon.GetHoldType(weapon)) or "normal"
            holdType = playeranimtype[holdType] or "passive"
            local tree = lia.anim.player[holdType]

            if tree and tree[act] then
                if type(tree[act]) == "string" then
                    client.CalcSeqOverride = client.LookupSequence(tree[act])

                    return
                else
                    return tree[act]
                end
            end
        end

        return self.BaseClass.TranslateActivity(self.BaseClass, client, act)
    end

    local tree = lia.anim[class]

    if tree then
        local subClass = "normal"

        if client.InVehicle(client) then
            local vehicle = client.GetVehicle(client)
            local class = vehicle:isChair() and "chair" or vehicle:GetClass()

            if tree.vehicle and tree.vehicle[class] then
                local act = tree.vehicle[class][1]
                local fixvec = tree.vehicle[class][2]

                if fixvec then
                    client:SetLocalPos(Vector(16.5438, -0.1642, -20.5493))
                end

                if type(act) == "string" then
                    client.CalcSeqOverride = client.LookupSequence(client, act)

                    return
                else
                    return act
                end
            else
                act = tree.normal[ACT_MP_CROUCH_IDLE][1]

                if type(act) == "string" then
                    client.CalcSeqOverride = client:LookupSequence(act)
                end

                return
            end
        elseif client.OnGround(client) then
            client.ManipulateBonePosition(client, 0, vector_origin)

            if IsValid(weapon) then
                subClass = weapon.HoldType or weapon.GetHoldType(weapon)
                subClass = defaultanimtype[subClass] or subClass
            end

            if tree[subClass] and tree[subClass][act] then
                local index = (not client.isWepRaised or client:isWepRaised()) and 2 or 1
                local act2 = tree[subClass][act][index]

                if type(act2) == "string" then
                    client.CalcSeqOverride = client.LookupSequence(client, act2)

                    return
                end

                return act2
            end
        elseif tree.glide then
            return tree.glide
        end
    end
end
--------------------------------------------------------------------------------------------------------
function GM:DoAnimationEvent(client, event, data)
    local class = lia.anim.getModelClass(client:GetModel())

    if class == "player" then
        return self.BaseClass:DoAnimationEvent(client, event, data)
    else
        local weapon = client:GetActiveWeapon()

        if IsValid(weapon) then
            local holdType = weapon.HoldType or weapon:GetHoldType()
            holdType = defaultanimtype[holdType] or holdType
            local animation = lia.anim[class][holdType]

            if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
                client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true)

                return ACT_VM_PRIMARYATTACK
            elseif event == PLAYERANIMEVENT_ATTACK_SECONDARY then
                client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.attack or ACT_GESTURE_RANGE_ATTACK_SMG1, true)

                return ACT_VM_SECONDARYATTACK
            elseif event == PLAYERANIMEVENT_RELOAD then
                client:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, animation.reload or ACT_GESTURE_RELOAD_SMG1, true)

                return ACT_INVALID
            elseif event == PLAYERANIMEVENT_JUMP then
                client.m_bJumping = true
                client.m_bFistJumpFrame = true
                client.m_flJumpStartTime = CurTime()
                client:AnimRestartMainSequence()

                return ACT_INVALID
            elseif event == PLAYERANIMEVENT_CANCEL_RELOAD then
                client:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD)

                return ACT_INVALID
            end
        end
    end

    return ACT_INVALID
end
--------------------------------------------------------------------------------------------------------
function GM:EntityEmitSound(data)
    if data.Entity.liaIsMuted then return false end
end
--------------------------------------------------------------------------------------------------------
local vectorAngle = FindMetaTable("Vector").Angle
local normalizeAngle = math.NormalizeAngle
local oldCalcSeqOverride

function GM:HandlePlayerLanding(client, velocity, wasOnGround)
    if client:GetMoveType() == MOVETYPE_NOCLIP then return end

    if client:IsOnGround() and not wasOnGround then
        local length = (client.lastVelocity or velocity):LengthSqr()
        local animClass = lia.anim.getModelClass(client:GetModel())
        if animClass ~= "player" and length < 100000 then return end
        client:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_LAND, true)

        return true
    end
end
--------------------------------------------------------------------------------------------------------
function GM:CalcMainActivity(client, velocity)
    client.CalcIdeal = ACT_MP_STAND_IDLE
    oldCalcSeqOverride = client.CalcSeqOverride
    client.CalcSeqOverride = -1
    local animClass = lia.anim.getModelClass(client:GetModel())

    if animClass ~= "player" then
        client:SetPoseParameter("move_yaw", normalizeAngle(vectorAngle(velocity)[2] - client:EyeAngles()[2]))
    end

    if self:HandlePlayerLanding(client, velocity, client.m_bWasOnGround) or self:HandlePlayerNoClipping(client, velocity) or self:HandlePlayerDriving(client) or self:HandlePlayerVaulting(client, velocity) or (usingPlayerAnims and self:HandlePlayerJumping(client, velocity)) or self:HandlePlayerSwimming(client, velocity) or self:HandlePlayerDucking(client, velocity) then
    else
        local len2D = velocity:Length2DSqr()

        if len2D > 22500 then
            client.CalcIdeal = ACT_MP_RUN
        elseif len2D > 0.25 then
            client.CalcIdeal = ACT_MP_WALK
        end
    end

    client.m_bWasOnGround = client:IsOnGround()
    client.m_bWasNoclipping = client:GetMoveType() == MOVETYPE_NOCLIP and not client:InVehicle()
    client.lastVelocity = velocity

    if CLIENT then
        client:SetIK(false)
    end

    return client.CalcIdeal, client.liaForceSeq or oldCalcSeqOverride
end
--------------------------------------------------------------------------------------------------------
function GM:OnCharVarChanged(char, varName, oldVar, newVar)
    if lia.char.varHooks[varName] then
        for k, v in pairs(lia.char.varHooks[varName]) do
            v(char, oldVar, newVar)
        end
    end
end
--------------------------------------------------------------------------------------------------------
function GM:GetDefaultCharName(client, faction)
    local info = lia.faction.indices[faction]
    if info and info.onGetDefaultName then return info:onGetDefaultName(client) end
end
--------------------------------------------------------------------------------------------------------
function GM:GetDefaultCharDesc(client, faction)
    local info = lia.faction.indices[faction]
    if info and info.onGetDefaultDesc then return info:onGetDefaultDesc(client) end
end
--------------------------------------------------------------------------------------------------------
function GM:CanPlayerUseChar(client, character)
    local banned = character:getData("banned")

    if banned then
        if isnumber(banned) and banned < os.time() then return end

        return false, "@charBanned"
    end

    if client:getChar() and client:getChar():getID() == character:getID() then return false, "You are already using this character!" end
    if client.LastDamaged and client.LastDamaged > CurTime() - 120 and character:getFaction() ~= FACTION_STAFF and client:getChar() then return false, "You took damage too recently to switch characters!" end
    if client:getNetVar("restricted") then return false, "You can't change characters while tied!" end

    if lia.config.CharacterSwitchCooldown and client:getChar() then
        if (client:getChar():getData("loginTime", 0) + lia.config.CharacterSwitchCooldownTimer) > os.time() then return false, "You are on cooldown!" end
        if not client:Alive() then return false, "You are dead!" end
    end
    
    local faction = lia.faction.indices[character:getFaction()]
    if faction and hook.Run("CheckFactionLimitReached", faction, character, client) then return false, "@limitFaction" end
end
--------------------------------------------------------------------------------------------------------
function GM:CheckFactionLimitReached(faction, character, client)
    if isfunction(faction.onCheckLimitReached) then return faction:onCheckLimitReached(character, client) end
    if not isnumber(faction.limit) then return false end
    local maxPlayers = faction.limit

    if faction.limit < 1 then
        maxPlayers = math.Round(#player.GetAll() * faction.limit)
    end

    return team.NumPlayers(faction.index) >= maxPlayers
end
--------------------------------------------------------------------------------------------------------
function GM:Move(client, moveData)
    local char = client:getChar()

    if char then
        if client:getNetVar("actAng") then
            moveData:SetForwardSpeed(0)
            moveData:SetSideSpeed(0)
        end

        if client:GetMoveType() == MOVETYPE_WALK and moveData:KeyDown(IN_WALK) then
            local mf, ms = 0, 0
            local speed = client:GetWalkSpeed()
            local ratio = lia.config.WalkRatio

            if moveData:KeyDown(IN_FORWARD) then
                mf = ratio
            elseif moveData:KeyDown(IN_BACK) then
                mf = -ratio
            end

            if moveData:KeyDown(IN_MOVELEFT) then
                ms = -ratio
            elseif moveData:KeyDown(IN_MOVERIGHT) then
                ms = ratio
            end

            moveData:SetForwardSpeed(mf * speed)
            moveData:SetSideSpeed(ms * speed)
        end
    end
end
--------------------------------------------------------------------------------------------------------
function GM:CanItemBeTransfered(itemObject, curInv, inventory)
    if itemObject.onCanBeTransfered then
        local itemHook = itemObject:onCanBeTransfered(curInv, inventory)

        return itemHook ~= false
    end
end
--------------------------------------------------------------------------------------------------------
function GM:OnPlayerJoinClass(client, class, oldClass)
    local info = lia.class.list[class]
    local info2 = lia.class.list[oldClass]

    if info.onSet then
        info:onSet(client)
    end

    if info2 and info2.onLeave then
        info2:onLeave(client)
    end

    netstream.Start(nil, "classUpdate", client)
end
--------------------------------------------------------------------------------------------------------
function GM:Think()
    if not self.nextThink then
        self.nextThink = 0
    end

    if self.nextThink < CurTime() then
        local players = player.GetAll()

        for k, v in pairs(players) do
            local hp = v:Health()
            local maxhp = v:GetMaxHealth()

            if hp < maxhp then
                local char = v:getChar()

                if lia.config.AutoRegen then
                    local newHP = hp + lia.config.HealingAmount
                    v:SetHealth(math.Clamp(newHP, 0, maxhp))
                end
            end
        end

        self.nextThink = CurTime() + lia.config.HealingTimer
    end
end
--------------------------------------------------------------------------------------------------------
function GM:PropBreak(attacker, ent)
    if IsValid(ent) and ent:GetPhysicsObject():IsValid() then
        constraint.RemoveAll(ent)
    end
end
--------------------------------------------------------------------------------------------------------
function GM:OnPickupMoney(client, moneyEntity)
    if moneyEntity and moneyEntity:IsValid() then
        local amount = moneyEntity:getAmount()
        client:getChar():giveMoney(amount)
        client:notifyLocalized("moneyTaken", lia.currency.get(amount))
    end
end
--------------------------------------------------------------------------------------------------------