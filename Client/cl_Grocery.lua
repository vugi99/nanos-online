
local energy_bars_text
local WaitingEnergyBuyConfirmation

local function GGetEBText()
    return "Number of energy bars : " .. tostring(Client.GetLocalPlayer():GetValue("EnergyBars")) .. " <br> Max energy bars : " .. tostring(Max_Energy_Bars)
end

function GroceryUI()
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Grocery Store")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        energy_bars_text = nil
        CloseDialog(dialog)
    end)

    local Energy_info_text = UIText()
    Energy_info_text.setContent("An energy bar can restore health (" .. tostring(Energy_Bar_Restored_Health) .. " HP)")
    Energy_info_text.appendTo(dialog)

    local Energy_text = UIText()
    Energy_text.setContent(GGetEBText())
    Energy_text.appendTo(dialog)
    energy_bars_text = Energy_text

    local BuyEnergyBarButton = UIButton()
    BuyEnergyBarButton.setTitle("Buy Energy Bar (" .. tostring(Energy_Bar_Price) .. "$)")
    BuyEnergyBarButton.onClick(function(obj)
        if OMoney - Energy_Bar_Price >= 0 then
            if Client.GetLocalPlayer():GetValue("EnergyBars") < Max_Energy_Bars then
                if not WaitingEnergyBuyConfirmation then
                    Events.CallRemote("BuyEnergyBar")
                    WaitingEnergyBuyConfirmation = true
                else
                    Chat.AddMessage("Please wait")
                end
            else
                Chat.AddMessage("Inventory Full")
            end
        else
            Chat.AddMessage("You don't have enough money")
        end
    end)
    BuyEnergyBarButton.appendTo(dialog)

    OpenDialog(dialog, true)
end



RegisterInteract("OnGroceryInteract", "GroceryVendor", function(ent) return "Interact with Grocery vendor" end, function(ent) return ent:GetHealth() > 0 end)

Events.Subscribe("OnGroceryInteract", function(char)
    ResetCanInteractWith()
    GroceryUI()
end)

Events.SubscribeRemote("EnergyBarBuyConfirmation", function()
    WaitingEnergyBuyConfirmation = nil
    if energy_bars_text then
        energy_bars_text.setContent(GGetEBText())
        energy_bars_text.update()
    end
end)


Timer.SetInterval(function()
    local ply = Client.GetLocalPlayer()
    if ply then
        local char = ply:GetControlledCharacter()
        if (char and char:GetHealth() > 0 and (not char:GetVehicle()) and (char:GetWeaponAimMode() ~= AimMode.None) and (not char:IsInRagdollMode())) then
            local picked_thing = char:GetPicked()
            --print("picked_thing", picked_thing)
            if (picked_thing and picked_thing:IsA(Weapon)) then
                local cam_loc = ply:GetCameraLocation()
                local cam_rot = ply:GetCameraRotation()
                local forward_vec = cam_rot:GetForwardVector()

                local trace_mode = TraceMode.ReturnEntity
                if ONLINE_DEV_IsModeEnabled("TRACES_DEBUG") then
                    trace_mode = trace_mode | TraceMode.DrawDebug
                end

                --print("TRACE")

                local trace = Trace.LineSingle(picked_thing:GetLocation(), cam_loc + forward_vec*Small_Heist_Trace_Distance, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.Pawn | CollisionChannel.PhysicsBody | CollisionChannel.Mesh | CollisionChannel.Vehicle, trace_mode, {char})
                if trace then
                    if trace.Success then
                        if (trace.Entity and trace.Entity:IsValid()) then
                            if trace.Entity.GetValue then
                                if trace.Entity:GetValue("GroceryVendor") then
                                    if (trace.Entity:GetHealth() > 0 and (not trace.Entity:IsInRagdollMode())) then
                                        Events.CallRemote("GroceryHeist", trace.Entity)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end, Small_Heist_Check_Aim_Interval_ms)