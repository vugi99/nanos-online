

Criminals = {}


function PlayerBecameCriminal(ply)
    if Policemans[ply] then
        SetPoliceman(ply, false)
    end
    Criminals[ply] = {tracked_by = {}}
    SetPlayerPassive(ply, false)
    LockPlayerPassive(ply, true)
    Events.CallRemote("SetCriminalClient", ply, true)
end

function PlayerNoLongerCriminal(ply)
    if PLAYERS_DATA[ply] then
        PLAYERS_DATA[ply].criminal_bonus = 0
        for k, v in pairs(Criminals[ply].tracked_by) do
            if k:IsValid() then
                Events.CallRemote("StopTracking", k)
            end
        end
        Criminals[ply] = nil
        LockPlayerPassive(ply, false)
        Events.CallRemote("SetCriminalClient", ply, false)
    end
end


function AddPlayerCriminalBonus(ply, mult)
    mult = mult or 1
    if PLAYERS_DATA[ply] then
        if PLAYERS_DATA[ply].criminal_bonus == 0 then
            PlayerBecameCriminal(ply)
        end

        PLAYERS_DATA[ply].criminal_bonus = PLAYERS_DATA[ply].criminal_bonus + Criminal_Bonus_Increase_Per_Crime*mult

        local dim = VDimension.GetObjectFromDimension(ply:GetDimension())
        if (dim and dim == DEFAULT_DIMENSION) then
            local char = ply:GetControlledCharacter()
            if char then
                local crime_loc = char:GetLocation()
                Timer.SetTimeout(function()
                    if ply:IsValid() then
                        if Criminals[ply] then
                            ply:SetValue("LastCrimeLocation", crime_loc, false)
                            for k, v in pairs(Criminals[ply].tracked_by) do
                                if k:IsValid() then
                                    Events.CallRemote("CriminalTrackingUpdate", k, crime_loc)
                                end
                            end
                        end
                    end
                end, Criminal_Crime_Get_KnownByPolice_After_ms)
            end
        end

        Events.CallRemote("CriminalAddedCrime", ply)
    end
end

Player.Subscribe("Destroy", function(ply)
    if Criminals[ply] then
        for k, v in pairs(Criminals[ply].tracked_by) do
            if k:IsValid() then
                Events.CallRemote("StopTracking", k)
            end
        end
    end
    Criminals[ply] = nil
end)

Events.Subscribe("PlayerDataLoaded", function(ply)
    ply:SetValue("LastCrimeLocation", nil, false)
    if PLAYERS_DATA[ply].criminal_bonus > 0 then
        PlayerBecameCriminal(ply)
    end
end)