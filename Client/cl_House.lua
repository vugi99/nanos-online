

function HouseBuyUI(house_id)
    if O_House_Entry_C then
        local house = SearchMapDataFirst(O_House_Entry_C, "House_ID", house_id)
        if house then
            local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
            local dialogPosition = UICSS()
            dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
            dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
            dialogPosition.width = "600px"

            local dialog = UIDialog()
            dialog.setTitle("House")
            dialog.appendTo(UIFramework)
            dialog.setCSS(dialogPosition)
            dialog.onClickClose(function(obj)
                CloseDialog(dialog)
            end)

            local text = UIText()
            text.setContent("House Price : " .. tostring(house.Price) .. "$")
            text.appendTo(dialog)

            local BuyButton = UIButton()
            BuyButton.setTitle("Buy House")
            BuyButton.onClick(function(obj)
                CloseDialog(dialog)
                Events.CallRemote("BuyHouse", house_id)
            end)
            BuyButton.appendTo(dialog)

            OpenDialog(dialog, true)
        end
    end
end


Events.SubscribeRemote("OpenHouseBuyUI", function(house_id)
    HouseBuyUI(house_id)
end)