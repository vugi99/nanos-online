
local Nametags_Text3Ds = {}

local ticked_chars = {}

Timer.SetInterval(function()
    ticked_chars = {}
    local local_char = Client.GetLocalPlayer():GetControlledCharacter()
    if local_char then
        for k, v in pairs(Player.GetPairs()) do
            if v ~= Client.GetLocalPlayer() then
                local char = v:GetControlledCharacter()
                if (char and (not char:GetVehicle()) and local_char:GetLocation():DistanceSquared(char:GetLocation()) <= Nametag_Distance_sq) then
                    if not Nametags_Text3Ds[char] then
                        --print(v:GetAccountName())
                        local text_3d = Online_Text3D(char, AttachmentRule.SnapToTarget, v:GetAccountName(), Vector(0.25, 0.25, 0.25), Color.AZURE, nil, Vector(0, 0, char:GetCapsuleSize().HalfHeight + 10))

                        Nametags_Text3Ds[char] = text_3d
                    end
                    ticked_chars[char] = true
                end
            end
        end
    end

    for k, v in pairs(Nametags_Text3Ds) do
        if k:IsValid() then
            if v:IsValid() then
                if (not ticked_chars[k]) then
                    v:Destroy()
                    Nametags_Text3Ds[k] = nil
                end
            end
        else
            Nametags_Text3Ds[k] = nil
        end
    end
end, Nametag_Check_Interval_ms)