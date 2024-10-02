

ONLINE_REGISTER_KEY("VehicleMenu", "F3")


function ClientIsVehicleDriver()
    local ply = Client.GetLocalPlayer()
    if (ply) then
        local char = ply:GetControlledCharacter()
        if char then
            local veh = char:GetVehicle()
            if veh then
                if (veh:GetPassenger(0) and (veh:GetPassenger(0) == char)) then
                    return true
                end
            end
        end
    end
end

function VehicleMenuUI()
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Player Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        CloseDialog(dialog)
    end)

    local KickButton = UIButton()
    KickButton.setTitle("Kick Vehicle Passengers")
    KickButton.onClick(function(obj)
        if ClientIsVehicleDriver() then
            Events.CallRemote("KickVehiclePassengers")
        end
    end)
    KickButton.appendTo(dialog)

    local StoreInGarage = UIButton()
    StoreInGarage.setTitle("Store In Garage")
    StoreInGarage.onClick(function(obj)
        if ClientIsVehicleDriver() then
            CloseDialog(dialog)
            Events.CallRemote("StoreVehicleInGarage")
        end
    end)
    StoreInGarage.appendTo(dialog)

    OpenDialog(dialog, true)
end

Input.Bind("VehicleMenu", InputEvent.Pressed, function()
    if IsDialogFree() then
        if ClientIsVehicleDriver() then
            VehicleMenuUI()
        end
    end
end)

Character.Subscribe("EnterVehicle", function(char, veh, seat)
	local ply = Client.GetLocalPlayer()
    local local_char = ply:GetControlledCharacter()
    if local_char == char then
        if (veh:GetValue("VehicleMaxHealth") and veh:GetValue("VehicleHealth")) then
            ONLINE_WEBUI:CallEvent("UpdateUIHealthVehicle", veh:GetValue("VehicleMaxHealth"), veh:GetValue("VehicleHealth"))
        end
    end
end)

Character.Subscribe("LeaveVehicle", function(char, veh)
	local ply = Client.GetLocalPlayer()
    local local_char = ply:GetControlledCharacter()
    if local_char == char then
        ONLINE_WEBUI:CallEvent("HideUIHealthVehicle")
    end
end)

Vehicle.Subscribe("ValueChange", function(veh, key, value)
    local ply = Client.GetLocalPlayer()
    local local_char = ply:GetControlledCharacter()
    if local_char then
        local local_veh = local_char:GetVehicle()
        if (local_veh and local_veh == veh) then
            if key == "VehicleHealth" then
                if veh:GetValue("VehicleMaxHealth") then
                    ONLINE_WEBUI:CallEvent("UpdateUIHealthVehicle", veh:GetValue("VehicleMaxHealth"), value)
                end
            end
        end
    end
end)

Vehicle.Subscribe("Destroy", function(veh)
    local ply = Client.GetLocalPlayer()
    local local_char = ply:GetControlledCharacter()
    if local_char then
        local local_veh = local_char:GetVehicle()
        if (local_veh and local_veh == veh) then
            ONLINE_WEBUI:CallEvent("HideUIHealthVehicle")
        end
    end
end)