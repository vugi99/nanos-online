
local Pickups_Waiting_Init = {}

local Pickups_Construction_Data = {}

local Pickups_Bounds_Cache = {}

function VPickup:Constructor(location, rotation, asset, overlap_only_classes, begin_overlap_func, end_overlap_func, scale, text_3d_text)
    self.Super:Constructor(location, rotation, asset, CollisionType.NoCollision)

    Pickups_Construction_Data[self] = {overlap_only_classes, begin_overlap_func, end_overlap_func, scale, text_3d_text}

    if scale then
        self:SetScale(scale)
    end

    Pickups_Waiting_Init[self] = true

    if Pickups_Bounds_Cache[asset] then
        scale = scale or Vector(1, 1, 1)

        local bounds = {Origin = CopyVector(Pickups_Bounds_Cache[asset].bounds.Origin), BoxExtent = CopyVector(Pickups_Bounds_Cache[asset].bounds.BoxExtent), SphereRadius = Pickups_Bounds_Cache[asset].bounds.SphereRadius}
        bounds.Origin = location + rotation:RotateVector(Pickups_Bounds_Cache[asset].Origin_Offset)
        bounds.BoxExtent = (scale*bounds.BoxExtent) / Pickups_Bounds_Cache[asset].scale

        InitVPickup(self, bounds)
    else
        local r_ply = GetRandomPlayerInDimension(DEFAULT_DIMENSION.ID)
        if r_ply then
            Events.CallRemote("InitPickupData", r_ply, self)
        end
    end
end

function VPickup:Destroy()
    if Pickups_Waiting_Init[self] then
        Pickups_Waiting_Init[self] = nil
    end

    if Pickups_Construction_Data[self] then
        Pickups_Construction_Data[self] = nil
    end

    self.Super:Destroy()
end

function VPickup:SetScale(scale)
    if self:GetValue("PickupTrigger") then
        if self:GetValue("PickupTrigger"):IsValid() then
            self:GetValue("PickupTrigger"):SetScale(scale)
        end
    end

    if Pickups_Construction_Data[self] then
        Pickups_Construction_Data[self][4] = scale
    end

    self.Super:SetScale(scale)
end

function VPickup:GetTrigger()
    if self:GetValue("PickupTrigger") then
        return self:GetValue("PickupTrigger")
    end
end

function InitVPickup(pickup, bounds)
    if (pickup and pickup:IsValid() and (not pickup.initialized)) then
        if Pickups_Construction_Data[pickup] then
            --print(NanosTable.Dump(bounds))

            local BoxExtent = CopyVector(bounds.BoxExtent)
            local Origin = CopyVector(bounds.Origin)
            if BoxExtent.Z < 150 then
                local delta = 150 - BoxExtent.Z
                BoxExtent.Z = BoxExtent.Z + (delta/2)
                Origin.Z = Origin.Z + (delta/2)
            end
            if BoxExtent.X < 25 then
                BoxExtent.X = 25
            end
            if BoxExtent.Y < 25 then
                BoxExtent.Y = 25
            end

            local box_trigger = Trigger(Origin, pickup:GetRotation(), BoxExtent, TriggerType.Box, ONLINE_DEV_IsModeEnabled("TRIGGERS_DEBUG"), Color.RED, Pickups_Construction_Data[pickup][1] or {})
            box_trigger:SetDimension(pickup:GetDimension())
            box_trigger:AttachTo(pickup, AttachmentRule.KeepWorld, "", 0, false)

            --print("box_trigger create in pickup:GetDimension()", box_trigger)

            pickup.initialized = true
            Pickups_Waiting_Init[pickup] = nil
            pickup:SetValue("PickupTrigger", box_trigger, false)

            box_trigger:Subscribe("Destroy", function(self)
                if pickup:IsValid() then
                    pickup:Destroy()
                end
            end)

            if Pickups_Construction_Data[pickup][2] then
                box_trigger:Subscribe("BeginOverlap", Pickups_Construction_Data[pickup][2])
            end
            if Pickups_Construction_Data[pickup][3] then
                box_trigger:Subscribe("EndOverlap", Pickups_Construction_Data[pickup][3])
            end

            if Pickups_Construction_Data[pickup][5] then
                Online_Text3D(pickup, AttachmentRule.KeepWorld, Pickups_Construction_Data[pickup][5], Vector(0.37, 0.37, 0.37), Color.WHITE, Vector(Origin.X, Origin.Y, Origin.Z + bounds.BoxExtent.Z + 10))
            end

            if (not Pickups_Bounds_Cache[pickup:GetMesh()]) then
                Pickups_Bounds_Cache[pickup:GetMesh()] = {
                    scale = (Pickups_Construction_Data[pickup][4] or Vector(1, 1, 1)),
                    bounds = bounds,
                    Origin_Offset = pickup:GetRotation():UnrotateVector(bounds.Origin - pickup:GetLocation()),
                }
            end

            Events.Call("VPickupInitialized", pickup, Origin, BoxExtent)
        end
    end
end

Events.SubscribeRemote("PickupBoundsData", function(ply, pickup, bounds)
    --print("PickupBoundsData", pickup, NanosTable.Dump(bounds))
    InitVPickup(pickup, bounds)
end)

Player.Subscribe("DimensionChange", function(ply, old_dimension, new_dimension)
	for k, v in pairs(Pickups_Waiting_Init) do
        if (k:GetDimension() == new_dimension) then
            Events.CallRemote("InitPickupData", ply, k)
        end
    end
end)