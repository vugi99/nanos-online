


function CheckLevelUp(ply, has_level_up)
    if PLAYERS_DATA[ply] then
        local XP_target = Levels_Function(PLAYERS_DATA[ply].level)
        if PLAYERS_DATA[ply].xp >= XP_target then
            PLAYERS_DATA[ply].xp = PLAYERS_DATA[ply].xp - XP_target
            PLAYERS_DATA[ply].level = PLAYERS_DATA[ply].level + 1
            CheckLevelUp(ply, true)
        elseif has_level_up then
            Events.CallRemote("UpdateClientLevel", ply, PLAYERS_DATA[ply].level)
        end
    end
end

function AddPlayerXP(ply, added)
    if (ply and ply:IsValid() and PLAYERS_DATA[ply]) then
        if (added and added > 0) then
            PLAYERS_DATA[ply].xp = PLAYERS_DATA[ply].xp + added
            CheckLevelUp(ply)
            Events.CallRemote("UpdateClientXP", ply, PLAYERS_DATA[ply].xp)
        end
    end
end

Events.Subscribe("PlayerDataLoaded", function(ply)
    CheckLevelUp(ply)
    Events.CallRemote("UpdateClientLevel", ply, PLAYERS_DATA[ply].level)
    Events.CallRemote("UpdateClientXP", ply, PLAYERS_DATA[ply].xp)
end)