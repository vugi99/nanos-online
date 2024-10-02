

Events.SubscribeRemote("InitPickupData", function(sm)
    if (sm and sm:IsValid()) then
        Events.CallRemote("PickupBoundsData", sm, sm:GetBounds())
    end
end)