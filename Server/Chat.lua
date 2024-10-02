

function ServerChatMessage(message)
    Chat.BroadcastMessage("<bold>[Server]</> : " .. message)
end

Events.Subscribe("PlayerDataLoaded", function(ply)
    ServerChatMessage(ply:GetAccountName() ..  " Joined")
end)

Player.Subscribe("Destroy", function(ply)
    ServerChatMessage(ply:GetAccountName() ..  " Left")
end)