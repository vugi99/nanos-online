


if O_Grocery_Vendor_C then
    for i, v in ipairs(O_Grocery_Vendor_C) do
        local vendor = Character(v.location + Vector(0, 0, 100), v.rotation, "nanos-world::SK_Mannequin")
        vendor:SetMaterialColorParameter("Tint", Color(1, 1, 0))
        vendor:SetValue("GroceryVendor", true, true)
        vendor:SetValue("NPCVendor", v, false)

        Online_Text3D(vendor, AttachmentRule.SnapToTarget, "Grocery Store", Vector(0.3, 0.3, 0.3), Color.WHITE, nil, Vector(0, 0, vendor:GetCapsuleSize().HalfHeight + 10))
    end
end

Events.Subscribe("PlayerDataLoaded", function(ply)
    ply:SetValue("EnergyBars", PLAYERS_DATA[ply].energy_bars, true)
end)

Events.SubscribeRemote("BuyEnergyBar", function(ply)
    if ply:IsValid() then
        local char = ply:GetControlledCharacter()
        if (char and char:IsValid() and char:GetHealth() > 0) then
            if PLAYERS_DATA[ply] then
                if PLAYERS_DATA[ply].energy_bars < Max_Energy_Bars then
                    if OBuy(ply, Energy_Bar_Price) then
                        PLAYERS_DATA[ply].energy_bars = PLAYERS_DATA[ply].energy_bars + 1
                        ply:SetValue("EnergyBars", PLAYERS_DATA[ply].energy_bars, true)

                        Events.CallRemote("AddNotification", ply, "Grocery Store", "Energy Bar Bought", 2500)
                    end
                end
            end
        end
        Events.CallRemote("EnergyBarBuyConfirmation", ply)
    end
end)

Events.SubscribeRemote("EatEnergyBar", function(ply)
    if ply:IsValid() then
        local char = ply:GetControlledCharacter()
        if (char and char:IsValid() and char:GetHealth() > 0) then
            if PLAYERS_DATA[ply] then
                if PLAYERS_DATA[ply].energy_bars > 0 then
                    PLAYERS_DATA[ply].energy_bars = PLAYERS_DATA[ply].energy_bars - 1
                    ply:SetValue("EnergyBars", PLAYERS_DATA[ply].energy_bars, true)

                    char:SetHealth(clamp(char:GetHealth(), 0, 100, Energy_Bar_Restored_Health))
                end
            end
        end
    end
end)

if ONLINE_DEV_IsModeEnabled("COMMANDS") then
    Chat.Subscribe("PlayerSubmit", function(text, ply)
        local char = ply:GetControlledCharacter()
        if char then
            local split_t = split_str(text, " ")
            if (split_t[1] and split_t[1] == "/dm") then
                if (split_t[2] and tonumber(split_t[2])) then
                    char:ApplyDamage(tonumber(split_t[2]), "", DamageType.Unknown)
                    return false
                end
            end
        end
    end)
end

Events.SubscribeRemote("GroceryHeist", function(ply, vendor)
    if (ply and ply:IsValid()) then
        local char = ply:GetControlledCharacter()
        if char then
            if (vendor and vendor:GetValue("GroceryVendor")) then
                if (not vendor:IsInRagdollMode() and vendor:GetHealth() > 0) then
                    local char_loc = vendor:GetLocation()
                    local frwrd = vendor:GetRotation():GetForwardVector()
                    char_loc = char_loc + frwrd*50

                    vendor:ApplyDamage(vendor:GetHealth(), "", DamageType.Unknown, Vector(0, 0, 0), nil, nil)

                    local p_money = math.random(Grocery_Heist_Ranges.Money[1], Grocery_Heist_Ranges.Money[2])
                    local xp_won = math.random(Grocery_Heist_Ranges.XP[1], Grocery_Heist_Ranges.XP[2])

                    local money_pickup = VPickup(Vector(char_loc.X, char_loc.Y, char_loc.Z-char:GetCapsuleSize().HalfHeight), char:GetRotation(), "nanos-world::SM_MoneyStack", {"Character"}, function(trigger, ent)
                        if (ent:GetPlayer() and ent:GetHealth() > 0) then
                            OAddMoney(ent:GetPlayer(), p_money)
                            AddPlayerXP(ent:GetPlayer(), xp_won)
                            AddPlayerCriminalBonus(ent:GetPlayer(), 3)
                            trigger:Destroy()

                            Events.CallRemote("AddNotification", ent:GetPlayer(), "", "You got " .. tostring(p_money) .. "$")
                        end
                    end, nil, nil, tostring(p_money) .. "$")
                    money_pickup:SetLifeSpan(Player_Death_Money_Drop_Lifespan_s)
                end
            end
        end
    end
end)