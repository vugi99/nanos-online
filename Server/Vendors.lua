

Character.Subscribe("Death", function(char, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    if char:GetValue("NPCVendor") then
        Timer.SetTimeout(function()
            if char:IsValid() then
                char:Respawn(char:GetValue("NPCVendor").location, char:GetValue("NPCVendor").rotation)
            end
        end, Vendor_Respawn_Time_s * 1000)
    end
end)

Character.Subscribe("RagdollModeChange", function(char, old_state, new_state)
	if char:GetValue("NPCVendor") then
        if new_state then
            Timer.SetTimeout(function()
                if (char:IsValid() and char:GetHealth() > 0) then
                    if char:IsInRagdollMode() then
                        char:SetRagdollMode(false)
                    end
                end
            end, 10000)
        end
    end
end)