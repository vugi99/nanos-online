


if O_Garage_Entry_C then
    for i, v in ipairs(O_Garage_Entry_C) do
        local garage_pickup = VPickup(v.location + Vector(0, 0, 100), v.rotation + Rotator(180, 0, 0), "nanos-world::SM_Cone", {"Character"}, function(trigger, ent)
            if (ent:GetPlayer() and ent:GetHealth() > 0 and (not ent:GetVehicle()) and (not ent:IsInRagdollMode())) then
                if not ent:GetValue("TPOnGarageEnterTrigger") then
                    if PLAYERS_DATA[ent:GetPlayer()] then
                        if not PlayerOwnsGarage(ent:GetPlayer(), v.Garage_ID) then
                            Events.CallRemote("OpenGarageBuyUI", ent:GetPlayer(), v.Garage_ID)
                        else
                            PlayerEnterGarage(ent:GetPlayer(), v.Garage_ID)
                        end
                    end
                else
                    ent:SetValue("TPOnGarageEnterTrigger", nil, false)
                end
            end
        end, nil, nil, "Garage " .. tostring(v.Garage_ID))
        garage_pickup:SetMaterial("nanos-world::M_Default_Translucent_Lit")
        garage_pickup:SetMaterialScalarParameter("Opacity", 0.9)
        garage_pickup:SetMaterialColorParameter("Tint", Color(1, 1, 0))
    end
end

function PlayerEnterGarage(ply, garage_id)
    if (ply and ply:IsValid()) then
        local char = ply:GetControlledCharacter()
        if (char and char:GetHealth() > 0) then
            if garage_id then
                local garage = SearchMapDataFirst(O_Garage_Entry_C, "Garage_ID", garage_id)
                local garage_exit = SearchMapDataFirst(O_Garage_Exit_C, "Garage_ID", garage_id)
                local garage_manage = SearchMapDataFirst(O_Garage_Manage_C, "Garage_ID", garage_id)

                local player_garage_data
                if PLAYERS_DATA[ply].garages.data then
                    for k, v in pairs(PLAYERS_DATA[ply].garages.data) do
                        if v.garage_id == garage_id then
                            player_garage_data = v
                        end
                    end
                end

                if (garage and garage_exit and player_garage_data) then
                    local garage_vehicle_slots = SearchMapData(O_Garage_VehicleSlot_C, "Garage_ID", garage_id)
                    local slots_count = table_count(garage_vehicle_slots)

                    local dim = VDimension.Create("Garage", true)

                    local exit_pickup = VPickup(garage_exit.location + Vector(0, 0, 100), garage_exit.rotation + Rotator(180, 0, 0), "nanos-world::SM_Cone", {"Character"}, function(trigger, ent)
                        if (ent:GetPlayer() and ent:GetHealth() > 0 and (not ent:GetVehicle())) then
                            if not ent:GetValue("TPOnGarageExitTrigger") then
                                if PLAYERS_DATA[ent:GetPlayer()] then
                                    ent:SetValue("TPOnGarageEnterTrigger", true, false)

                                    ent:SetLocation(garage.location + Vector(0, 0, 100))
                                    ent:SetRotation(garage.rotation)

                                    ent:GetPlayer():SetDimension(DEFAULT_DIMENSION:GetID())
                                end
                            else
                                ent:SetValue("TPOnGarageExitTrigger", nil, false)
                            end
                        end
                    end, nil, nil, "Exit")
                    exit_pickup:SetDimension(dim:GetID())
                    exit_pickup:SetMaterial("nanos-world::M_Default_Translucent_Lit")
                    exit_pickup:SetMaterialScalarParameter("Opacity", 0.9)
                    exit_pickup:SetMaterialColorParameter("Tint", Color(1, 1, 0))

                    local fake_pickup = VPickup(garage_exit.location + Vector(0, 0, 100), Rotator(), "nanos-world::SM_Cone", {"Character"}, function(trigger, ent)

                    end)
                    fake_pickup:SetDimension(dim:GetID())
                    fake_pickup:SetVisibility(false)

                    if garage_manage then
                        local manage_pickup = VPickup(garage_manage.location + Vector(0, 0, 100), garage_manage.rotation, "nanos-world::SM_Cylinder", {"Character"}, function(trigger, ent)
                            if (ent:GetPlayer() and ent:GetHealth() > 0 and (not ent:GetVehicle())) then
                                if PLAYERS_DATA[ent:GetPlayer()] then
                                    if PLAYERS_DATA[ent:GetPlayer()].garages.data then
                                        Events.CallRemote("OpenGarageManageUI", ent:GetPlayer(), garage_id, PLAYERS_DATA[ent:GetPlayer()].garages)
                                    end
                                end
                            end
                        end, nil, nil, "Manage")
                        manage_pickup:SetDimension(dim:GetID())
                        manage_pickup:SetMaterial("nanos-world::M_Default_Translucent_Lit")
                        manage_pickup:SetMaterialScalarParameter("Opacity", 0.9)
                        manage_pickup:SetMaterialColorParameter("Tint", Color(1, 1, 0))

                        local fake_pickup_2 = VPickup(garage_manage.location + Vector(0, 0, 100), Rotator(), "nanos-world::SM_Cylinder", {"Character"}, function(trigger, ent)

                        end)
                        fake_pickup_2:SetDimension(dim:GetID())
                        fake_pickup_2:SetVisibility(false)
                    end

                    char:SetValue("TPOnGarageExitTrigger", true, false)
                    char:SetLocation(garage_exit.location + Vector(0, 0, 100))
                    char:SetRotation(garage_exit.rotation)
                    ply:SetDimension(dim:GetID())

                    local plyveh = GetPlayerSpawnedVehicle(ply)

                    for k, v in pairs(player_garage_data.vehicles) do
                        if Car_Dealer_Vehicles[v.name] then
                            if ((not plyveh) or (not plyveh:GetValue("GVID")) or (plyveh:GetValue("GVID") ~= v.gvid)) then
                                if slots_count > 0 then
                                    local selected_slot = garage_vehicle_slots[1]
                                    table.remove(garage_vehicle_slots, 1)
                                    slots_count = slots_count - 1
                                    local veh = SpawnOnlineVehicle(selected_slot.location + Vector(0, 0, 20), selected_slot.rotation, Car_Dealer_Vehicles[v.name].func, Car_Dealer_Vehicles[v.name].health)
                                    veh:SetDimension(dim:GetID())
                                    veh:SetValue("GVID", v.gvid, false)
                                    veh:SetValue("Garage_ID", garage_id, false)
                                end
                            end
                        end
                    end
                end
            else
                error("Missing garage_id : PlayerEnterGarage")
            end
        end
    end
end

function PlayerOwnsGarage(ply, garage_id)
    if PLAYERS_DATA[ply] then
        if PLAYERS_DATA[ply].garages.data then
            for i, v in ipairs(PLAYERS_DATA[ply].garages.data) do
                if v.garage_id == garage_id then
                    return true
                end
            end
        end
    end
end

Events.SubscribeRemote("BuyGarage", function(ply, garage_id)
    if (ply and ply:IsValid()) then
        if PLAYERS_DATA[ply] then
            if garage_id then
                local garage = SearchMapDataFirst(O_Garage_Entry_C, "Garage_ID", garage_id)
                if garage then
                    if not PlayerOwnsGarage(ply, garage_id) then
                        if OBuy(ply, garage.Price) then
                            if not PLAYERS_DATA[ply].garages.LastVehicleID then
                                PLAYERS_DATA[ply].garages.LastVehicleID = 0
                                PLAYERS_DATA[ply].garages.data = {}
                            end

                            table.insert(PLAYERS_DATA[ply].garages.data, {
                                garage_id = garage_id,
                                vehicles = {},
                            })

                            Events.CallRemote("AddNotification", ply, "Garage", "Garage " .. tostring(garage_id) .. " Bought", 10000)
                        end
                    end
                end
            end
        end
    end
end)

function SpawnPlayerGarageVehicle(ply, gvid, loc, rot)
    if (ply and ply:IsValid()) then
        local char = ply:GetControlledCharacter()
        if char then
            if PLAYERS_DATA[ply] then
                if gvid then
                    if PLAYERS_DATA[ply].garages.data then
                        local found_veh
                        for i, v in ipairs(PLAYERS_DATA[ply].garages.data) do
                            for k2, v2 in pairs(v.vehicles) do
                                if v2.gvid == gvid then
                                    found_veh = v2
                                end
                            end
                        end
                        if found_veh then
                            if Car_Dealer_Vehicles[found_veh.name] then
                                local veh = SpawnOnlineVehicle(loc, rot, Car_Dealer_Vehicles[found_veh.name].func, Car_Dealer_Vehicles[found_veh.name].health)
                                veh:SetValue("GVID", gvid, false)
                                char:EnterVehicle(veh, 0)

                                SpawnedPlayerVehicle(ply, veh)

                                return veh
                            end
                        end
                    end
                end
            end
        end
    end
end

Character.Subscribe("AttemptEnterVehicle", function(char, veh, seat)
    if seat == 0 then
        local ply = char:GetPlayer()
        if ply then
            if veh:GetValue("Garage_ID") then
                if O_Garage_Vehicle_EntryExit_C then
                    local garage_veh_exit = SearchMapDataFirst(O_Garage_Vehicle_EntryExit_C, "Garage_ID", veh:GetValue("Garage_ID"))
                    if garage_veh_exit then
                        veh:SetValue("Garage_ID", nil, false)
                        veh:SetLocation(garage_veh_exit.location + Vector(0, 0, 20))
                        veh:SetRotation(garage_veh_exit.rotation)
                        veh:SetDimension(DEFAULT_DIMENSION:GetID())
                        ply:SetDimension(DEFAULT_DIMENSION:GetID())
                        SpawnedPlayerVehicle(ply, veh)
                    end
                end
            end
        end
    end
end)

Events.SubscribeRemote("SellVehicle", function(ply, garage_id, selected)
    if (ply and ply:IsValid()) then
        if PLAYERS_DATA[ply] then
            if (garage_id and selected and selected.gvid and selected.name and Car_Dealer_Vehicles[selected.name]) then
                if PLAYERS_DATA[ply].garages.data then
                    local dim = VDimension.GetObjectFromDimension(ply:GetDimension())
                    if (dim and dim:GetName() == "Garage") then
                        local sold
                        for i, v in ipairs(PLAYERS_DATA[ply].garages.data) do
                            if v.garage_id == garage_id then
                                for i2, v2 in ipairs(v.vehicles) do
                                    if v2.gvid == selected.gvid then
                                        OAddMoney(ply, math.floor(Car_Dealer_Vehicles[selected.name].price * Sell_Vehicle_Price_Mult))
                                        table.remove(PLAYERS_DATA[ply].garages.data[i].vehicles, i2)
                                        sold = true
                                        break
                                    end
                                end
                                break
                            end
                        end
                        if sold then
                            for k, v in pairs(dim:GetEntitiesOfClass("Vehicle")) do
                                if k:GetValue("GVID") == selected.gvid then
                                    k:Destroy()
                                    break
                                end
                            end
                            Events.CallRemote("AddNotification", ply, "Garage", "You sold " .. selected.name .. " for " .. tostring(math.floor(Car_Dealer_Vehicles[selected.name].price * Sell_Vehicle_Price_Mult)) .. "$", 10000)
                        end
                    end
                end
            end
        end
    end
end)

Events.SubscribeRemote("StoreVehicleInGarage", function(ply)
    if (ply and ply:IsValid()) then
        local char = ply:GetControlledCharacter()
        if char then
            local veh = char:GetVehicle()
            if veh then
                if (veh:GetPassenger(0) and (veh:GetPassenger(0) == char)) then
                    if (veh:GetValue("GVID") and (veh == GetPlayerSpawnedVehicle(ply))) then
                        DestroyPlayerVehicle(ply)
                        Events.CallRemote("AddNotification", ply, "Vehicle", "Stored vehicle in garage", 10000)
                    else
                        Events.CallRemote("AddNotification", ply, "Vehicle", "You cannot store this vehicle")
                    end
                end
            end
        end
    end
end)