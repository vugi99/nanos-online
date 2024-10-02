
local PlayersVehicles = {}

function DestroyPlayerVehicle(ply)
    if PlayersVehicles[ply] then
        if PlayersVehicles[ply]:IsValid() then
            PlayersVehicles[ply]:Destroy()
        end
        PlayersVehicles[ply] = nil
    end
end

function SpawnedPlayerVehicle(ply, veh)
    DestroyPlayerVehicle(ply)

    PlayersVehicles[ply] = veh
end

function GetPlayerSpawnedVehicle(ply)
    return PlayersVehicles[ply]
end

Player.Subscribe("Destroy", function(ply)
    DestroyPlayerVehicle(ply)
end)

Character.Subscribe("AttemptEnterVehicle", function(char, veh, seat)
    if seat == 0 then
        local ply = char:GetPlayer()
        if ply then
            if veh:GetValue("VehicleDead") then
                Events.CallRemote("AddNotification", ply, "Vehicle", "Cannot Enter Dead Vehicle")
                return false
            end
            local dim = VDimension.GetObjectFromDimension(veh:GetDimension())
            if dim then
                if dim == DEFAULT_DIMENSION then
                    if (veh:GetValue("PoliceCar") and (not Policemans[ply])) then
                        Events.CallRemote("AddNotification", ply, "Vehicle", "Cannot Enter Police Vehicle")
                        return false
                    elseif ((not PlayersVehicles[ply]) or (PlayersVehicles[ply] ~= veh)) then
                        Events.CallRemote("AddNotification", ply, "Vehicle", "Cannot Enter Vehicle")
                        return false
                    end
                end
            end
        end
    end
end)

Events.SubscribeRemote("KickVehiclePassengers", function(ply)
    if (ply and ply:IsValid()) then
        local char = ply:GetControlledCharacter()
        if char then
            local veh = char:GetVehicle()
            if veh then
                if (veh:GetPassenger(0) and (veh:GetPassenger(0) == char)) then
                    for k, v in pairs(veh:GetPassengers()) do
                        if v ~= char then
                            v:LeaveVehicle()
                        end
                    end
                    Events.CallRemote("AddNotification", ply, "Vehicle", "Kicked Passengers")
                end
            end
        end
    end
end)

function SpawnOnlineVehicle(loc, rot, func, max_health)
    if (loc and rot and func) then
        local veh = func(loc, rot)
        veh:SetValue("VehicleDead", false, true)
        veh:SetValue("VehicleMaxHealth", max_health, true)
        veh:SetValue("VehicleHealth", max_health, true)
        return veh
    end
end

function DamageVehicle(veh, damage, instigator, causer)
    local veh_h = veh:GetValue("VehicleHealth")
    local veh_max_h = veh:GetValue("VehicleMaxHealth")
    if (veh_h) then
        if (not veh:GetValue("VehicleDead")) then
            veh_h = veh_h - damage
            if veh_h < 0 then
                veh_h = 0
            end

            veh:SetValue("VehicleHealth", veh_h, true)

            if ((veh_h <= veh_max_h*Vehicle_Smoke_From_Health_Mult) and (not veh:GetValue("VehSmoke"))) then
                local p_smoke = Particle(
                    Vector(),
                    Rotator(0, 0, 0),
                    "nanos-world::P_Smoke",
                    false,
                    true
                )
                p_smoke:AttachTo(veh, AttachmentRule.SnapToTarget, "", 0, false)
                p_smoke:SetRelativeLocation(Vector(100, 0, 100))

                veh:SetValue("VehSmoke", p_smoke, false)
            end

            if veh_h == 0 then
                veh:SetValue("VehicleDead", true, true)
                Particle(
                    veh:GetLocation() + Vector(0, 0, 100),
                    veh:GetRotation(),
                    "nanos-world::P_Explosion",
                    true,
                    true
                )

                local p_fire = Particle(
                    Vector(),
                    Rotator(0, 0, 0),
                    "nanos-world::P_Fire",
                    false,
                    true
                )
                p_fire:AttachTo(veh, AttachmentRule.SnapToTarget, "", 0, false)
                p_fire:SetRelativeLocation(Vector(100, 0, 100))

                for k, v in pairs(veh:GetPassengers()) do
                    v:ApplyDamage(v:GetHealth(), "", DamageType.Explosion, Vector(), instigator, causer)
                end

                for k, v in pairs(PlayersVehicles) do
                    if v == veh then
                        PlayersVehicles[k] = nil
                    end
                end

                veh:SetEngineStarted(false)

                veh:SetLifeSpan(Vehicle_Explode_Lifespan_s)

                if instigator then
                    AddPlayerXP(instigator, DestroyVehicle_XP)

                    if not Policemans[instigator] then
                        AddPlayerCriminalBonus(instigator, 2)
                    end
                end
            end
        end
    end
end

Vehicle.Subscribe("Hit", function(veh, impact_force, normal_impulse, impact_location, velocity)
	--print("Vehicle Hit", impact_force, normal_impulse, impact_location, velocity)
    DamageVehicle(veh, impact_force*Vehicle_Hit_Impact_Force_Multiplier_For_Damage)
end)

Vehicle.Subscribe("TakeDamage", function(veh, damage, bone, type, from_direction, instigator, causer)
	--print("Vehicle TakeDamage", damage, bone, type, from_direction, instigator, causer)
    DamageVehicle(veh, damage, instigator, causer)
end)