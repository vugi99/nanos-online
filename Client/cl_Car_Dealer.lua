

function CarDealerUI(car_dealer_id, garages)
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 500) / 2) .. "px"
    dialogPosition.left = math.floor(50) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Car Dealer")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        Events.CallRemote("LeaveCarDealer", car_dealer_id)
        CloseDialog(dialog)
    end)

    local vehtext = UIText()
    vehtext.setContent("Select a vehicle : ")
    vehtext.appendTo(dialog)

    --local colortext = UIText()
    --colortext.setContent("Select a color : ")

    local garagetext = UIText()
    garagetext.setContent("Select a garage : ")

    local ColorPosition = UICSS()
    ColorPosition.left = "300px !important"

    --[[local ColorPicker = UIColorPicker()
    ColorPicker.onChange(function(obj, value)
        local r, g, b, a = obj.getValueAsRGBA()
        local car
        for i,v in ipairs(GetStreamedVehicles()) do
           car = v
           break
        end
        if car then
           SetVehicleColor(car, RGB(r, g, b, a*255))
        end
    end)
    ColorPicker.setCSS(ColorPosition)]]--
    local BuyButton = UIButton()
    BuyButton.setTitle("Select a car")

    local CarsList = UIOptionList()
    local _index = 0
    local _veh_list = {}
    for k, v in pairs(Car_Dealer_Vehicles) do
        CarsList.appendOption(_index, k .. " " .. tostring(v.price) .. "$")
        table.insert(_veh_list, k)
        _index = _index + 1
    end
    CarsList.appendTo(dialog)
    local selected = nil
    local price = nil
    CarsList.onChange(function(obj)
        selected = _veh_list[obj.getValue()[1]+1]
        price = Car_Dealer_Vehicles[_veh_list[obj.getValue()[1]+1]].price
        BuyButton.setTitle("Buy Car (" .. tostring(price) .. "$)")
        BuyButton.update()
        Events.CallRemote("CarDealerShowcaseCar", car_dealer_id, selected)
    end)

    local GarageList = UIOptionList()
    for i, v in ipairs(garages.data) do
        local free_slots = table_count(SearchMapData(O_Garage_VehicleSlot_C, "Garage_ID", v.garage_id))
        GarageList.appendOption(i-1, "Garage " .. tostring(v.garage_id) .. ", " .. tostring(free_slots - table_count(v.vehicles)) .. " free slots")
    end
    local selectedgarage = nil
    GarageList.onChange(function(obj)
       selectedgarage = garages.data[obj.getValue()[1] + 1].garage_id
    end)
    --colortext.appendTo(dialog)
    --ColorPicker.appendTo(dialog)

    garagetext.appendTo(dialog)
    GarageList.appendTo(dialog)

    BuyButton.onClick(function(obj)
        if selected then
            if selectedgarage then
                if OMoney >= price then
                    --local r, g, b, a = ColorPicker.getValueAsRGBA()
                    CloseDialog(dialog)
                    Events.CallRemote("CarDealerBuyVehicle", car_dealer_id, selected, selectedgarage)
                else
                    Chat.AddMessage("You don't have enough money to buy this car")
                end
            else
                Chat.AddMessage("Please Select a garage")
            end
        else
            Chat.AddMessage("Please Select a vehicle")
        end
    end)
    BuyButton.appendTo(dialog)

    OpenDialog(dialog, true)
end


RegisterInteract("OnCarDealerInteract", "CarDealerVendor", function(ent) return "Interact with Car Dealer" end, function(ent) return ent:GetHealth() > 0 end)

Events.Subscribe("OnCarDealerInteract", function(char)
    Events.CallRemote("AskCarDealerServer", char:GetValue("CarDealerVendor"))
end)

Events.SubscribeRemote("OpenCarDealerUI", function(car_dealer_id, garages)
    CarDealerUI(car_dealer_id, garages)
end)