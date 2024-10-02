

function GarageBuyUI(garage_id)
    if O_Garage_VehicleSlot_C then
        local garage = SearchMapDataFirst(O_Garage_Entry_C, "Garage_ID", garage_id)
        if garage then

            local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
            local dialogPosition = UICSS()
            dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
            dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
            dialogPosition.width = "600px"

            local dialog = UIDialog()
            dialog.setTitle("Garage")
            dialog.appendTo(UIFramework)
            dialog.setCSS(dialogPosition)
            dialog.onClickClose(function(obj)
                CloseDialog(dialog)
            end)

            local text = UIText()
            text.setContent("Garage Price : " .. tostring(garage.Price) .. "$ <br> Garage Slots : " .. tostring(table_count(SearchMapData(O_Garage_VehicleSlot_C, "Garage_ID", garage_id))))
            text.appendTo(dialog)

            local BuyButton = UIButton()
            BuyButton.setTitle("Buy Garage")
            BuyButton.onClick(function(obj)
                CloseDialog(dialog)
                Events.CallRemote("BuyGarage", garage_id)
            end)
            BuyButton.appendTo(dialog)

            OpenDialog(dialog, true)
        end
    end
end

function GarageManageUI(garage_id, garages)
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Manage Garage")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        CloseDialog(dialog)
    end)

    local selltext = UIText()
    selltext.setContent("Sell A Vehicle")
    selltext.appendTo(dialog)

    local SellButton = UIButton()

    local SellList = UIOptionList()
    local g_table_id
    for i, v in ipairs(garages.data) do
        if v.garage_id == garage_id then
            g_table_id = i
            for i2, v2 in ipairs(v.vehicles) do
                if Car_Dealer_Vehicles[v2.name] then
                    SellList.appendOption(i2-1, "Vehicle " .. tostring(v2.name) .. ", value : " .. tostring(math.floor(Car_Dealer_Vehicles[v2.name].price * Sell_Vehicle_Price_Mult)) .. "$")
                end
            end
            break
        end
    end
    SellList.appendTo(dialog)
    local selected = nil
    SellList.onChange(function(obj)
        selected = garages.data[g_table_id].vehicles[obj.getValue()[1]+1]
        SellButton.setTitle("Sell Vehicle (" .. tostring(math.floor(Car_Dealer_Vehicles[selected.name].price * Sell_Vehicle_Price_Mult)) .. "$)")
        SellButton.update()
    end)

    SellButton.setTitle("Select a vehicle")
    SellButton.onClick(function(obj)
        if selected then
            CloseDialog(dialog)
            Events.CallRemote("SellVehicle", garage_id, selected)
        else
            Chat.AddMessage("Please select a vehicle")
        end
    end)
    SellButton.appendTo(dialog)

    OpenDialog(dialog, true)
end

Events.SubscribeRemote("OpenGarageBuyUI", function(garage_id)
    GarageBuyUI(garage_id)
end)

Events.SubscribeRemote("OpenGarageManageUI", function(garage_id, garages)
    GarageManageUI(garage_id, garages)
end)