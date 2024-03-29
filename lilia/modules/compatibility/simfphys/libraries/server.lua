﻿function MODULE:simfphysUse(entity, client)
    if entity.IsBeingEntered then client:notify("Someone is entering this car!") end
    if entity.IsLocked then client:notify("This car is locked!") end
    if lia.config.CarEntryDelayEnabled and entity:IsSimfphysCar() and lia.config.TimeToEnterVehicle > 0 then
        entity.IsBeingEntered = true
        client:setAction("Entering Vehicle...", lia.config.TimeToEnterVehicle)
        client:doStaredAction(entity, function()
            entity.IsBeingEntered = false
            entity:SetPassenger(client)
        end, lia.config.TimeToEnterVehicle, function()
            if IsValid(entity) then
                entity.IsBeingEntered = false
                client:setAction()
            end

            if IsValid(client) then client:setAction() end
        end)
    end
    return true
end

function MODULE:OnEntityCreated(entity)
    if entity:IsSimfphysCar() then
        entity.PhysicsCollideBack = entity.PhysicsCollide
        entity.PhysicsCollide = function(vehicle, data, physobj)
            if not self.DamageInCars then
                entity:PhysicsCollideBack(data, physobj)
                return
            end

            if data.DeltaTime < 0.2 then return end
            local speed = data.Speed
            local mass = 1
            local hitEnt = data.HitEntity
            if not hitEnt:IsWorld() then mass = math.Clamp(data.HitObject:GetMass() / physobj:GetMass(), 0, 1) end
            local dmg = speed * speed * mass / 5000
            if not dmg or dmg < 1 then return end
            local pos = data.HitPos
            if hitEnt.IsSimfphyscar then
                local vel = data.OurOldVelocity
                local tvel = data.TheirOldVelocity
                local dif = data.OurNewVelocity - tvel
                local dot = -dif:Dot(tvel:GetNormalized())
                local fwd = vehicle:GetForward()
                local lpos = vehicle:WorldToLocal(pos)
                local side = 1 - math.abs(fwd:Dot((pos - vehicle:GetPos()):GetNormalized()))
                dmg = dmg * math.Clamp(dot / speed, 0.1, 0.9) * damageMul
                print("Dmg:", dmg, "\nSpeed:", speed, "\nVel:", vel, "\nTVel:", tvel, "\nDif:", dif, "\nDot:", dot / speed, "\nLPos:", lpos, "\nSideMult:", side)
            end

            if dmg >= 100 then
                sound.Play(Sound("MetalVehicle.ImpactHard"), pos)
            elseif dmg >= 10 then
                sound.Play(Sound("MetalVehicle.ImpactSoft"), pos)
            end

            local dmginfo = DamageInfo()
            dmginfo:SetDamage(dmg)
            dmginfo:SetAttacker(hitEnt)
            dmginfo:SetInflictor(vehicle)
            dmginfo:SetDamageType(DMG_CRUSH)
            dmginfo:SetDamagePosition(pos)
            local force = Vector((vehicle:GetPos() - pos):GetNormalized() * dmg * physobj:GetMass() * 100)
            dmginfo:SetDamageForce(force)
            vehicle:TakeDamageInfo(dmginfo)
        end
    end
end

function MODULE:EntityTakeDamage(entity, dmgInfo)
    local damageType = dmgInfo:GetDamageType()
    if self.DamageInCars and entity:IsVehicle() and table.HasValue(self.ValidCarDamages, damageType) then
        local client = entity:GetDriver()
        if IsValid(client) then
            local hitPos = dmgInfo:GetDamagePosition()
            local clientPos = client:GetPos()
            local thresholdDistance = 53
            if hitPos:Distance(clientPos) <= thresholdDistance then
                local newHealth = client:Health() - (dmgInfo:GetDamage() * 0.3)
                if newHealth > 0 then
                    client:SetHealth(newHealth)
                else
                    client:Kill()
                end
            end
        end
    end
end

function MODULE:isSuitableForTrunk(entity)
    if IsValid(entity) and entity:IsSimfphysCar() then return true end
end

function MODULE:CheckValidSit(client, _)
    local entity = client:GetTracedEntity()
    if entity:IsSimfphysCar() then return false end
end

function MODULE:KeyLock(client, entity, time)
    if IsValid(entity) and client:GetPos():Distance(entity:GetPos()) <= 256 and (entity:IsSimfphysCar() and entity:GetCreator() == client) then
        client:setAction("@locking", time, function() end)
        client:doStaredAction(entity, function() self:ToggleLock(client, entity, true) end, time, function() client:setAction() end)
    end
end

function MODULE:KeyUnlock(client, entity, time)
    if IsValid(entity) and client:GetPos():Distance(entity:GetPos()) <= 256 and (entity:IsSimfphysCar() and entity:GetCreator() == client or client:IsSuperAdmin() or client:isStaffOnDuty()) then
        client:setAction("@unlocking", time, function() end)
        client:doStaredAction(entity, function() self:ToggleLock(client, entity, false) end, time, function() client:setAction() end)
    end
end

function MODULE:ToggleLock(client, entity, state)
    entity.IsLocked = not state
    entity:Fire(state and "lock" or "unlock")
    client:EmitSound(state and "doors/door_latch3.wav" or "doors/door_latch1.wav")
    if state then
        entity:Lock()
    else
        entity:UnLock()
    end
end

function MODULE:InitializedModules()
    for k, v in pairs(self.SimfphysConsoleCommands) do
        RunConsoleCommand(k, v)
    end
end