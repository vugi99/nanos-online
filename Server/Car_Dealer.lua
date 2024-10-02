

if O_CarDealer_C then
    for i, v in ipairs(O_CarDealer_C) do
        local vendor = Character(v.location + Vector(0, 0, 100), v.rotation, "nanos-world::SK_Mannequin")
        vendor:SetMaterialColorParameter("Tint", Color(1, 0.2, 0))
        vendor:SetValue("CarDealerVendor", v.Car_Dealer_ID, true)
        vendor:SetValue("NPCVendor", v, false)

        Online_Text3D(vendor, AttachmentRule.SnapToTarget, "Car Dealer", Vector(0.3, 0.3, 0.3), Color.WHITE, nil, Vector(0, 0, vendor:GetCapsuleSize().HalfHeight + 10))
    end
end

Events.SubscribeRemote("AskCarDealerServer", function(ply, car_dealer_id)
    if (O_CarDealer_C and O_CarDealer_Vehicle_C) then
        if (ply and ply:IsValid()) then
            local char = ply:GetControlledCharacter()
            if (char and char:GetHealth() > 0) then
                if car_dealer_id then
                    if (PLAYERS_DATA[ply].garages.data and table_count(PLAYERS_DATA[ply].garages.data) > 0) then
                        local car_dealer = SearchMapDataFirst(O_CarDealer_C, "Car_Dealer_ID", car_dealer_id)
                        local car_dealer_vehicle_slot = SearchMapDataFirst(O_CarDealer_Vehicle_C, "Car_Dealer_ID", car_dealer_id)

                        if (car_dealer and car_dealer_vehicle_slot) then
                            if PLAYERS_DATA[ply] then
                                local dim = VDimension.Create("Car Dealer", true)

                                char:SetLocation(car_dealer_vehicle_slot.location + Vector(0, 0, 100))
                                char:SetRotation(car_dealer_vehicle_slot.rotation)
                                ply:SetDimension(dim:GetID())

                                Events.CallRemote("OpenCarDealerUI", ply, car_dealer_id, PLAYERS_DATA[ply].garages)
                            end
                        end
                    else
                        Events.CallRemote("AddNotification", ply, "Car Dealer", "You don't have any garage")
                    end
                end
            end
        end
    end
end)

Events.SubscribeRemote("CarDealerShowcaseCar", function(ply, car_dealer_id, selected)
    if (O_CarDealer_C and O_CarDealer_Vehicle_C) then
        if (ply and ply:IsValid()) then
            local char = ply:GetControlledCharacter()
            if (char and char:GetHealth() > 0) then
                if (car_dealer_id and selected and Car_Dealer_Vehicles[selected]) then
                    local car_dealer_vehicle_slot = SearchMapDataFirst(O_CarDealer_Vehicle_C, "Car_Dealer_ID", car_dealer_id)

                    if car_dealer_vehicle_slot then
                        local dim = VDimension.GetObjectFromDimension(ply:GetDimension())
                        if dim:GetName() == "Car Dealer" then
                            local vehs = dim:GetEntitiesOfClassCopy("Vehicle")
                            if vehs then
                                for k, v in pairs(vehs) do
                                    if k:IsValid() then
                                        k:Destroy()
                                    end
                                end
                            end

                            local veh = SpawnOnlineVehicle(car_dealer_vehicle_slot.location + Vector(0, 0, 20), car_dealer_vehicle_slot.rotation, Car_Dealer_Vehicles[selected].func, Car_Dealer_Vehicles[selected].health)
                            veh:SetDimension(dim:GetID())
                            char:EnterVehicle(veh, 0)
                        end
                    end
                end
            end
        end
    end
end)

function LeaveCarDealer(ply, car_dealer_id)
    ply:SetDimension(DEFAULT_DIMENSION:GetID())
end
Events.SubscribeRemote("LeaveCarDealer", LeaveCarDealer)

Events.SubscribeRemote("CarDealerBuyVehicle", function(ply, car_dealer_id, selected_veh, selected_garage_id)
    --print("CarDealerBuyVehicle", ply, car_dealer_id, selected_veh, selected_garage_id)
    if (ply and ply:IsValid()) then
        local char = ply:GetControlledCharacter()
        if char then
            --print("1")
            if (selected_garage_id and selected_veh and Car_Dealer_Vehicles[selected_veh]) then
                --print("2")
                local dim = VDimension.GetObjectFromDimension(ply:GetDimension())
                if dim:GetName() == "Car Dealer" then
                    --print("3")
                    LeaveCarDealer(ply, car_dealer_id)

                    if OBuy(ply, Car_Dealer_Vehicles[selected_veh].price) then
                        local car_dealer_vehicle_slot = SearchMapDataFirst(O_CarDealer_Vehicle_C, "Car_Dealer_ID", car_dealer_id)

                        if car_dealer_vehicle_slot then
                            if PLAYERS_DATA[ply] then
                                if (PLAYERS_DATA[ply].garages.data and PLAYERS_DATA[ply].garages.LastVehicleID) then

                                    local garage_selected
                                    for i, v in ipairs(PLAYERS_DATA[ply].garages.data) do
                                        if v.garage_id == selected_garage_id then
                                            garage_selected = PLAYERS_DATA[ply].garages.data[i]
                                        end
                                    end

                                    if garage_selected then
                                        local free_slots = table_count(SearchMapData(O_Garage_VehicleSlot_C, "Garage_ID", selected_garage_id)) -  table_count(garage_selected.vehicles)

                                        if free_slots > 0 then
                                            PLAYERS_DATA[ply].garages.LastVehicleID = PLAYERS_DATA[ply].garages.LastVehicleID + 1
                                            table.insert(garage_selected.vehicles, {
                                                name = selected_veh,
                                                gvid = PLAYERS_DATA[ply].garages.LastVehicleID,
                                            })

                                            Events.CallRemote("AddNotification", ply, "Car Dealer", selected_veh .. " added in garage " .. tostring(selected_garage_id), 10000)

                                            AddPlayerXP(ply, BuyVehicle_XP)

                                            SpawnPlayerGarageVehicle(ply, PLAYERS_DATA[ply].garages.LastVehicleID, car_dealer_vehicle_slot.location + Vector(0, 0, 20), car_dealer_vehicle_slot.rotation)
                                        else
                                            Events.CallRemote("AddNotification", ply, "Car Dealer", "This Garage is full", 10000)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)