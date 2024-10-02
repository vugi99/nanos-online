

if O_House_Entry_C then
    for i, v in ipairs(O_House_Entry_C) do
        local house_pickup = VPickup(v.location + Vector(0, 0, 100), v.rotation + Rotator(180, 0, 0), "nanos-world::SM_Cone", {"Character"}, function(trigger, ent)
            if (ent:GetPlayer() and ent:GetHealth() > 0 and (not ent:GetVehicle()) and (not ent:IsInRagdollMode())) then
                if not ent:GetValue("TPOnHouseEnterTrigger") then
                    if PLAYERS_DATA[ent:GetPlayer()] then
                        if not PlayerOwnsHouse(ent:GetPlayer(), v.House_ID) then
                            Events.CallRemote("OpenHouseBuyUI", ent:GetPlayer(), v.House_ID)
                        else
                            PlayerEnterHouse(ent:GetPlayer(), v.House_ID)
                        end
                    end
                else
                    ent:SetValue("TPOnHouseEnterTrigger", nil, false)
                end
            end
        end, nil, nil, "House " .. tostring(v.House_ID))
        house_pickup:SetMaterial("nanos-world::M_Default_Translucent_Lit")
        house_pickup:SetMaterialScalarParameter("Opacity", 0.9)
        house_pickup:SetMaterialColorParameter("Tint", Color(1, 1, 0))
    end
end

function PlayerEnterHouse(ply, house_id)
    if (ply and ply:IsValid()) then
        local char = ply:GetControlledCharacter()
        if (char and char:GetHealth() > 0) then
            if house_id then
                local house = SearchMapDataFirst(O_House_Entry_C, "House_ID", house_id)
                local house_exit = SearchMapDataFirst(O_House_Exit_C, "House_ID", house_id)
                local heist_start = SearchMapDataFirst(O_Heist_Start_C, "House_ID", house_id)

                if (house and house_exit) then
                    local dim = VDimension.Create("House", true)

                    local exit_pickup = VPickup(house_exit.location + Vector(0, 0, 100), house_exit.rotation + Rotator(180, 0, 0), "nanos-world::SM_Cone", {"Character"}, function(trigger, ent)
                        if (ent:GetPlayer() and ent:GetHealth() > 0 and (not ent:GetVehicle())) then
                            if not ent:GetValue("TPOnHouseExitTrigger") then
                                if PLAYERS_DATA[ent:GetPlayer()] then
                                    ent:SetValue("TPOnHouseEnterTrigger", true, false)

                                    ent:SetLocation(house.location + Vector(0, 0, 100))
                                    ent:SetRotation(house.rotation)

                                    ent:GetPlayer():SetDimension(DEFAULT_DIMENSION:GetID())
                                end
                            else
                                ent:SetValue("TPOnHouseExitTrigger", nil, false)
                            end
                        end
                    end, nil, nil, "Exit")
                    exit_pickup:SetDimension(dim:GetID())
                    exit_pickup:SetMaterial("nanos-world::M_Default_Translucent_Lit")
                    exit_pickup:SetMaterialScalarParameter("Opacity", 0.9)
                    exit_pickup:SetMaterialColorParameter("Tint", Color(1, 1, 0))

                    local fake_pickup = VPickup(house_exit.location + Vector(0, 0, 100), Rotator(), "nanos-world::SM_Cone", {"Character"}, function(trigger, ent)

                    end)
                    fake_pickup:SetDimension(dim:GetID())
                    fake_pickup:SetVisibility(false)

                    if heist_start then
                        local heist_pickup = VPickup(heist_start.location + Vector(0, 0, 100), heist_start.rotation + Rotator(180, 0, 0), "nanos-world::SM_Cone", {"Character"}, function(trigger, ent)
                            if (ent:GetPlayer() and ent:GetHealth() > 0 and (not ent:GetVehicle())) then

                            end
                        end, nil, nil, "Heist")
                        heist_pickup:SetDimension(dim:GetID())
                        heist_pickup:SetMaterial("nanos-world::M_Default_Translucent_Lit")
                        heist_pickup:SetMaterialScalarParameter("Opacity", 0.9)
                        heist_pickup:SetMaterialColorParameter("Tint", Color(1, 1, 0))

                        local fake_pickup2 = VPickup(heist_start.location + Vector(0, 0, 100), Rotator(), "nanos-world::SM_Cone", {"Character"}, function(trigger, ent)

                        end)
                        fake_pickup2:SetDimension(dim:GetID())
                        fake_pickup2:SetVisibility(false)
                    end

                    char:SetValue("TPOnHouseExitTrigger", true, false)
                    char:SetLocation(house_exit.location + Vector(0, 0, 100))
                    char:SetRotation(house_exit.rotation)
                    ply:SetDimension(dim:GetID())
                end
            else
                error("Missing house_id : PlayerEnterHouse")
            end
        end
    end
end

function PlayerOwnsHouse(ply, house_id)
    if PLAYERS_DATA[ply] then
        for i, v in ipairs(PLAYERS_DATA[ply].houses) do
            if v.house_id == house_id then
                return true
            end
        end
    end
end

Events.SubscribeRemote("BuyHouse", function(ply, house_id)
    if (ply and ply:IsValid()) then
        if PLAYERS_DATA[ply] then
            if house_id then
                local house = SearchMapDataFirst(O_House_Entry_C, "House_ID", house_id)
                if house then
                    if not PlayerOwnsHouse(ply, house_id) then
                        if OBuy(ply, house.Price) then
                            table.insert(PLAYERS_DATA[ply].houses, {
                                house_id = house_id,
                            })

                            Events.CallRemote("AddNotification", ply, "House", "House " .. tostring(house_id) .. " Bought", 10000)
                        end
                    end
                end
            end
        end
    end
end)