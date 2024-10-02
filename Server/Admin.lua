


Events.Subscribe("PlayerDataLoaded", function(ply)
    if Online_Admins[tostring(ply:GetSteamID())] then
        Events.CallRemote("IsAdminInfo", ply, true)
    end
end)

Events.SubscribeRemote("ToggleNoclip", function(ply)
    if Online_Admins[tostring(ply:GetSteamID())] then
        local char = ply:GetControlledCharacter()
        if char then
            char:SetFlyingMode(not char:GetFlyingMode())
        end
    end
end)