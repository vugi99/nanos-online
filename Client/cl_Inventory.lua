
ONLINE_REGISTER_KEY("Switch Weapon", "X")

Input.Bind("Switch Weapon", InputEvent.Pressed, function()
    local ply = Client.GetLocalPlayer()
    if ply then
        local char = ply:GetControlledCharacter()
        if char then
            if (char:GetHealth() > 0 and (not char:GetVehicle())) then
                if (not One_Time_Updates_Data.PassiveEnabled) then
                    Events.CallRemote("Online_Switch_Weapon")
                else
                    AddNotification("Passive", "Cannot equip weapons in passive mode", 2500)
                end
            end
        end
    end
end)