

if O_GunStoreVendor_C then
    for i, v in ipairs(O_GunStoreVendor_C) do
        local vendor = Character(v.location + Vector(0, 0, 100), v.rotation, "nanos-world::SK_Mannequin")
        vendor:SetMaterialColorParameter("Tint", Color(1, 0, 0))
        vendor:SetValue("GunshopVendor", v.Gun_Store_ID, true)
        vendor:SetValue("NPCVendor", v, false)

        Online_Text3D(vendor, AttachmentRule.SnapToTarget, "Gunshop", Vector(0.3, 0.3, 0.3), Color.WHITE, nil, Vector(0, 0, vendor:GetCapsuleSize().HalfHeight + 10))
    end
end

Events.SubscribeRemote("AskGunshopServer", function(ply, gunshop_id)
    if (O_GunStoreVendor_C and O_GunStore_Weap_Preview_C and O_GunStore_Weap_Preview_Cam_C) then
        if (ply and ply:IsValid() and PLAYERS_DATA[ply]) then
            local char = ply:GetControlledCharacter()
            if char then
                if (char:GetHealth() > 0 and (not char:GetVehicle()) and (not char:IsInRagdollMode()) and gunshop_id) then
                    local weap_preview = SearchMapDataFirst(O_GunStore_Weap_Preview_C, "Gun_Store_ID", gunshop_id)
                    local weap_preview_cam = SearchMapDataFirst(O_GunStore_Weap_Preview_Cam_C, "Gun_Store_ID", gunshop_id)

                    if (weap_preview and weap_preview_cam) then
                        local dim = VDimension.Create("Gunshop", true)
                        ply:SetDimension(dim:GetID())
                        ply:UnPossess()

                        ply:SetCameraLocation(weap_preview_cam.location)
                        ply:SetCameraRotation(weap_preview_cam.rotation)

                        Events.CallRemote("OpenGunshopUI", ply, gunshop_id, PLAYERS_DATA[ply].weapons, PLAYERS_DATA[ply].weapons_picked, PLAYERS_DATA[ply].ammos)
                    end
                end
            end
        end
    end
end)

Events.SubscribeRemote("ShowcaseWeapon", function(ply, gunshop_id, selected)
    if (ply and ply:IsValid()) then
        if (gunshop_id and selected) then
            local gunshop_weap_preview = SearchMapDataFirst(O_GunStore_Weap_Preview_C, "Gun_Store_ID", gunshop_id)
            if gunshop_weap_preview then
                if Online_Weapons[selected] then
                    local dim = VDimension.GetObjectFromDimension(ply:GetDimension())
                    if (dim and (dim:GetName() == "Gunshop")) then
                        for k, v in pairs(dim:GetEntitiesOfClassCopy("Weapon")) do
                            k:Destroy()
                        end
                        local weap_p = Online_Weapons[selected].func(gunshop_weap_preview.location, gunshop_weap_preview.rotation)
                        weap_p:SetGravityEnabled(false)
                        weap_p:SetDimension(dim:GetID())
                    end
                end
            end
        end
    end
end)

function LeaveGunshop(ply)
    if (ply and ply:IsValid() and PLAYERS_DATA[ply]) then
        local dim = VDimension.GetObjectFromDimension(ply:GetDimension())
        if (dim and dim:GetName() == "Gunshop") then
            local char
            for k, v in pairs(dim:GetEntitiesOfClass("Character")) do
                char = k
                break
            end
            if char then
                ply:Possess(char)
                ply:SetDimension(DEFAULT_DIMENSION:GetID())
                UpdateCurrentWeaponAmmo(char)
                return true
            else
                error("Cannot find char in LeaveGunshop !")
            end
        end
    end
end
Events.SubscribeRemote("LeaveGunshop", LeaveGunshop)

Events.SubscribeRemote("GunshopSelectWeapon", function(ply, selected, selected_slot)
    if (ply and ply:IsValid() and PLAYERS_DATA[ply]) then
        if (selected and selected_slot and (selected_slot <= 3)) then
            local left = LeaveGunshop(ply)
            if left then
                local char = ply:GetControlledCharacter()
                if char then
                    if Online_Weapons[selected] then
                        if PLAYERS_DATA[ply].weapons_picked[selected] then
                            Events.CallRemote("AddNotification", ply, "Gunshop", "This weapon is already equipped", 10000)
                            return
                        end

                        local weap_picked_in_sslot
                        for k, v in pairs(PLAYERS_DATA[ply].weapons_picked) do
                            if v.slot == selected_slot then
                                weap_picked_in_sslot = k
                            end
                        end

                        if PLAYERS_DATA[ply].weapons[selected] then
                            if weap_picked_in_sslot then
                                PLAYERS_DATA[ply].weapons_picked[weap_picked_in_sslot] = nil
                                RemoveCharacterWeapon(char, selected_slot)
                            end
                            PLAYERS_DATA[ply].weapons_picked[selected] = {slot = selected_slot}
                            AddCharacterWeapon(char, selected, true, selected_slot)
                            if PLAYERS_DATA[ply].passive then
                                EquipSlot(char, 4)
                            end

                            Events.CallRemote("AddNotification", ply, "Gunshop", selected .. " Equipped", 10000)
                        else
                            if OBuy(ply, Online_Weapons[selected].price) then
                                PLAYERS_DATA[ply].weapons[selected] = {}
                                if weap_picked_in_sslot then
                                    PLAYERS_DATA[ply].weapons_picked[weap_picked_in_sslot] = nil
                                    RemoveCharacterWeapon(char, selected_slot)
                                end
                                PLAYERS_DATA[ply].weapons_picked[selected] = {slot = selected_slot}
                                AddCharacterWeapon(char, selected, true, selected_slot)
                                if PLAYERS_DATA[ply].passive then
                                    EquipSlot(char, 4)
                                end

                                if (not PLAYERS_DATA[ply].ammos[Online_Weapons[selected].ammo_type] or PLAYERS_DATA[ply].ammos[Online_Weapons[selected].ammo_type] <= 0) then
                                    PLAYERS_DATA[ply].ammos[Online_Weapons[selected].ammo_type] = Online_Ammo_Types[Online_Weapons[selected].ammo_type].sell_unit
                                    UpdateCurrentWeaponAmmo(char)
                                end

                                AddPlayerXP(ply, BuyWeapon_XP)

                                Events.CallRemote("AddNotification", ply, "Gunshop", selected .. " Bought", 10000)
                            end
                        end
                    end
                end
            end
        end
    end
end)

Events.SubscribeRemote("GunshopBuyAmmo", function(ply, selected_ammo)
    if (ply and ply:IsValid() and PLAYERS_DATA[ply]) then
        if selected_ammo then
            if Online_Ammo_Types[selected_ammo] then
                if (not PLAYERS_DATA[ply].ammos[selected_ammo]) then
                    PLAYERS_DATA[ply].ammos[selected_ammo] = 0
                end
                if (PLAYERS_DATA[ply].ammos[selected_ammo] < Online_Ammo_Types[selected_ammo].max_ammo) then
                    if OBuy(ply, Online_Ammo_Types[selected_ammo].price) then
                        AddPlayerXP(ply, BuyAmmo_XP)

                        PLAYERS_DATA[ply].ammos[selected_ammo] = clamp(PLAYERS_DATA[ply].ammos[selected_ammo], 0, Online_Ammo_Types[selected_ammo].max_ammo, Online_Ammo_Types[selected_ammo].sell_unit)

                        Events.CallRemote("UpdateGunshopAmmos", ply, PLAYERS_DATA[ply].ammos)

                        Events.CallRemote("AddNotification", ply, "Gunshop", selected_ammo .. " Ammo Bought " .. "(x" .. tostring(Online_Ammo_Types[selected_ammo].sell_unit) .. ")")
                    end
                else
                    Events.CallRemote("AddNotification", ply, "Gunshop", selected_ammo .. " Ammo Full")
                end
            end
        end
    end
end)