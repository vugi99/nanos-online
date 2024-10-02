
local Can_Interact_With

local Interact_Actions = {}

local Interact_Triggers = {}

function RegisterInteract(event_name, look_for_value, text_func, additional_check_func)
    if (event_name and look_for_value and text_func and type(text_func) == "function" and type(event_name) == "string" and type(look_for_value) == "string") then
        table.insert(Interact_Actions, {event_name, look_for_value, text_func, additional_check_func})
        return true
    else
        Console.Error("Wrong RegisterInteract arguments")
    end
end

function RegisterVTriggerInteract(event_name, look_for_value, text_func, additional_check_func)
    if (event_name and look_for_value and text_func and type(text_func) == "function" and type(event_name) == "string" and type(look_for_value) == "string") then
        table.insert(Interact_Triggers, {event_name, look_for_value, text_func, additional_check_func})
        return true
    else
        Console.Error("Wrong RegisterVTriggerInteract arguments")
    end
end

function ResetCanInteractWith(internal)
    if (internal and Can_Interact_With and Can_Interact_With[3]) then return false end
    if Can_Interact_With then
        One_Time_Updates_Data.InteractText = nil
        One_Time_Updates_Canvas:Repaint()
    end
    Can_Interact_With = nil
end

Timer.SetInterval(function()
    ResetCanInteractWith(true)
    local ply = Client.GetLocalPlayer()
    if ply then
        local char = ply:GetControlledCharacter()
        if (char and (char:GetHealth() > 0) and (not char:IsInRagdollMode())) then
            if (not char:GetVehicle()) then
                if IsDialogFree() then
                    local forward_vec = char:GetRotation():GetForwardVector()

                    local trace_mode = TraceMode.ReturnEntity
                    if ONLINE_DEV_IsModeEnabled("TRACES_DEBUG") then
                        trace_mode = trace_mode | TraceMode.DrawDebug
                    end

                    local trace = Trace.LineSingle(char:GetLocation(), char:GetLocation() + forward_vec*Interact_Trace_Distance, CollisionChannel.WorldStatic | CollisionChannel.WorldDynamic | CollisionChannel.Pawn | CollisionChannel.PhysicsBody | CollisionChannel.Mesh | CollisionChannel.Vehicle, trace_mode, {char})
                    if trace.Success then
                        if (trace.Entity and trace.Entity:IsValid()) then
                            if trace.Entity.GetValue then
                                for i, v in ipairs(Interact_Actions) do
                                    if trace.Entity:GetValue(v[2]) then
                                        local good = false
                                        if v[4] then
                                            if v[4](trace.Entity) then
                                                good = true
                                            end
                                        else
                                            good = true
                                        end
                                        if good then
                                            Can_Interact_With = {trace.Entity, v, false}
                                            One_Time_Updates_Data.InteractText = v[3](trace.Entity)
                                            One_Time_Updates_Canvas:Repaint()
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
end, Interact_Interval_ms)

Input.Bind("Interact", InputEvent.Pressed, function()
    local ply = Client.GetLocalPlayer()
    if ply then
        local char = ply:GetControlledCharacter()
        if (char and (char:GetHealth() > 0) and (not char:IsInRagdollMode())) then
            if (not char:GetVehicle()) then
                if Can_Interact_With then
                    Events.Call(Can_Interact_With[2][1], Can_Interact_With[1])
                end
            end
        end
    end
end)

VTrigger.Subscribe("BeginOverlap", function(trigger, entity)
	if (entity and entity:IsValid()) then
        local char = Client.GetLocalPlayer():GetControlledCharacter()
        if (char and char:GetHealth() > 0 and (not char:IsInRagdollMode())) then
            if (not char:GetVehicle()) then
                if entity == char then
                    for i, v in ipairs(Interact_Triggers) do
                        if trigger:GetValue(v[2]) then
                            local good = false
                            if v[4] then
                                if v[4](trigger) then
                                    good = true
                                end
                            else
                                good = true
                            end
                            if good then
                                Can_Interact_With = {trigger, v, true}
                                One_Time_Updates_Data.InteractText = v[3](trigger)
                                One_Time_Updates_Canvas:Repaint()
                            end
                        end
                    end
                end
            end
        end
    end
end)

VTrigger.Subscribe("EndOverlap", function(trigger, entity)
	if (entity and entity:IsValid()) then
        local char = Client.GetLocalPlayer():GetControlledCharacter()
        if char then
            if entity == char then
                if Can_Interact_With then
                    if Can_Interact_With[3] then
                        if Can_Interact_With[1] == trigger then
                            ResetCanInteractWith()
                        end
                    end
                end
            end
        end
    end
end)