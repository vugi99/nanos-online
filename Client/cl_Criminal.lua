

IsCriminal = nil

Events.SubscribeRemote("SetCriminalClient", function(cr)
    IsCriminal = cr
    if IsCriminal then
        AddNotification("Criminal", "You are now a Criminal (You now have a bonus on your head)")
    else
        AddNotification("Criminal", "You are no longer a Criminal")
    end
    One_Time_Updates_Canvas:Repaint()
end)

Events.SubscribeRemote("CriminalAddedCrime", function()
    AddNotification("Criminal", "Criminal Action (Added bonus on your head)")
end)