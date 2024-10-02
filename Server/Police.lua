

Policemans = {}

local PoliceCarSpawners_Cooldowns = {}

if O_Police_Recruiter_C then
    for i, v in ipairs(O_Police_Recruiter_C) do
        local police_recruiter = Character(v.location + Vector(0, 0, 100), v.rotation, "nanos-world::SK_Mannequin")
        police_recruiter:SetMaterialColorParameter("Tint", Color.AZURE)
        police_recruiter:SetValue("PoliceRecruiter", true, true)
        police_recruiter:SetValue("NPCVendor", v, false)

        Online_Text3D(police_recruiter, AttachmentRule.SnapToTarget, "Police", Vector(0.3, 0.3, 0.3), Color.WHITE, nil, Vector(0, 0, police_recruiter:GetCapsuleSize().HalfHeight + 10))
    end
end

function SetPoliceman(ply, value)
    if (ply and ply:IsValid()) then
        if ((value and (not Policemans[ply])) or ((not value) and Policemans[ply])) then
            if value then
                Policemans[ply] = true
                SetPlayerPassive(ply, false)
                LockPlayerPassive(ply, true)
            else
                Policemans[ply] = nil
                RemovePlyFromTracker(ply)
                LockPlayerPassive(ply, false)
            end
            local char = ply:GetControlledCharacter()
            if char then
                if value then
                    char:SetMesh("nanos-world::SK_Mannequin")
                    char:SetMaterialColorParameter("Tint", Color.AZURE)
                else
                    char:SetMesh(PLAYERS_DATA[ply].skin)
                end
            end

            Events.CallRemote("PoliceChangedClient", ply, value)
        end
    end
end

Events.SubscribeRemote("JoinPolice", function(ply)
    if (ply:IsValid()) then
        if not Policemans[ply] then
            if not Criminals[ply] then
                if next(PLAYERS_DATA[ply].weapons) ~= nil then
                    SetPoliceman(ply, true)
                else
                    Events.CallRemote("AddNotification", ply, "Police", "You need a weapon to join police")
                end
            else
                PoliceArrestCriminal(ply)
            end
        end
    end
end)

Events.SubscribeRemote("LeavePolice", function(ply)
    if (ply:IsValid()) then
        if Policemans[ply] then
            SetPoliceman(ply, false)
        end
    end
end)

function RemovePlyFromTracker(ply, dont_callremote)
    for k, v in pairs(Criminals) do
        if Criminals[k].tracked_by[ply] then
            Criminals[k].tracked_by[ply] = nil
        end
    end
    if not dont_callremote then
        Events.CallRemote("StopTracking", ply)
    end
end

Player.Subscribe("Destroy", function(ply)
    RemovePlyFromTracker(ply, true)
    Policemans[ply] = nil
end)

if O_Police_Car_Spawner_C then
    for i, v in ipairs(O_Police_Car_Spawner_C) do
        Online_Text3D(nil, nil, "Police Car Spawner", Vector(0.3, 0.3, 0.3), Color.WHITE, v.location + Vector(0, 0, 250), nil)
    end
end

Events.SubscribeRemote("SpawnPoliceCar", function(ply, spawner_id)
    if (ply and ply:IsValid()) then
        local char = ply:GetControlledCharacter()
        if char then
            if char:GetHealth() > 0 then
                if (not char:GetVehicle()) then
                    if Policemans[ply] then
                        if O_Police_Car_Spawner_C[spawner_id] then
                            if not PoliceCarSpawners_Cooldowns[spawner_id] then
                                local dim = VDimension.GetObjectFromDimension(ply:GetDimension())
                                if (dim and dim == DEFAULT_DIMENSION) then
                                    PoliceCarSpawners_Cooldowns[spawner_id] = Timer.SetTimeout(function()
                                        PoliceCarSpawners_Cooldowns[spawner_id] = nil
                                    end, PoliceCarSpawnerCooldown_ms)

                                    local veh = SpawnOnlineVehicle(O_Police_Car_Spawner_C[spawner_id].location + Vector(0, 0, 20), O_Police_Car_Spawner_C[spawner_id].rotation, SpecialVehicles.Police, 7000)
                                    veh:SetValue("PoliceCar", true, false)
                                    char:EnterVehicle(veh, 0)
                                    SpawnedPlayerVehicle(ply, veh)
                                end
                            else
                                Events.CallRemote("AddNotification", ply, "Police", "Car Spawner In Cooldown")
                            end
                        end
                    end
                end
            end
        end
    end
end)

local testcriminals = false

Events.SubscribeRemote("GetCriminalsForPoliceMenu", function(ply)
    if Policemans[ply] then
        local Criminals_SEND = {}
        local tblin = 1
        Criminals_SEND[tblin] = {}
        if not testcriminals then
            for k, v in pairs(Criminals) do
                if k:IsValid() then
                    if PLAYERS_DATA[k] then
                        local tbl = {}
                        tbl.name = k:GetAccountName()
                        tbl.criminal_bonus = PLAYERS_DATA[k].criminal_bonus
                        tbl.level = PLAYERS_DATA[k].level
                        tbl.ply = k
                        table.insert(Criminals_SEND[tblin], tbl)
                        if table_count(Criminals_SEND[tblin]) > 14 then
                            tblin = tblin + 1
                            Criminals_SEND[tblin] = {}
                        end
                    end
                end
            end
            Events.CallRemote("ReceiveCriminalsForUI", ply, Criminals_SEND)
        else
            for i = 1, 299 do
                local tbl = {}
                tbl.name = "test"
                tbl.criminal_bonus = i
                tbl.level = i
                tbl.ply = i
                table.insert(Criminals_SEND[tblin], tbl)
                if table_count(Criminals_SEND[tblin]) > 14 then
                    tblin = tblin + 1
                    Criminals_SEND[tblin] = {}
                end
            end
            Events.CallRemote("ReceiveCriminalsForUI", ply, Criminals_SEND)
        end
    end
end)

Events.SubscribeRemote("TrackCriminal", function(ply, track_ply)
    if (ply and ply:IsValid() and track_ply) then
        if Policemans[ply] then
            if type(track_ply) == "number" then
                print("TrackCriminal", track_ply)
            else
                if Criminals[track_ply] then
                    RemovePlyFromTracker(ply)
                    Criminals[track_ply].tracked_by[ply] = true
                    Events.CallRemote("StartTracking", ply, track_ply:GetAccountName(), track_ply:GetValue("LastCrimeLocation"))
                end
            end
        end
    end
end)

function PoliceArrestCriminal(ply)
    if Criminals[ply] then
        RemoveAllPickedWeapons(ply)
        local char = ply:GetControlledCharacter()
        if char then
            char:SetRagdollMode(true)
        end
        PlayerNoLongerCriminal(ply)
        Events.CallRemote("PlayWasted", ply)
        Events.CallRemote("AddNotification", ply, "Police", "You Got Arrested (You lost equipped weapons)", 10000)
    end
end
Events.SubscribeRemote("PoliceArrestCriminal", PoliceArrestCriminal)