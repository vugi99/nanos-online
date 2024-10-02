
IS_ONLINE_ADMIN = nil

Events.SubscribeRemote("IsAdminInfo", function(is_admin)
    IS_ONLINE_ADMIN = is_admin
end)

function AdminUI()
    if IsDialogFree() then
        local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
        local dialogPosition = UICSS()
        dialogPosition.top = math.floor((ScreenY - 300) / 2) .. "px"
        dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
        dialogPosition.width = "600px"

        local dialog = UIDialog()
        dialog.setTitle("Admin Menu")
        dialog.appendTo(UIFramework)
        dialog.setCSS(dialogPosition)
        dialog.onClickClose(function(obj)
            CloseDialog(obj)
        end)

        local NoclipButton = UIButton()
        NoclipButton.setTitle("Toggle Noclip")
        NoclipButton.onClick(function(obj)
            Events.CallRemote("ToggleNoclip")
        end)
        NoclipButton.appendTo(dialog)

        OpenDialog(dialog)
    end
end

ONLINE_REGISTER_KEY("Admin Menu", "F10")

Input.Bind("Admin Menu", InputEvent.Pressed, function()
    --print("Admin Menu Open")
    if IS_ONLINE_ADMIN then
        AdminUI()
    end
end)

