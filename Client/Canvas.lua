

One_Time_Updates_Data = {}

One_Time_Updates_Canvas = Canvas(
    true,
    Color.TRANSPARENT,
    -1,
    true
)

One_Time_Updates_Canvas:Subscribe("Update", function(self, width, height)
    if One_Time_Updates_Data.InteractText then
        self:DrawText(
            One_Time_Updates_Data.InteractText,
            (Viewport.GetViewportSize() / 2) + Vector2D(0, Interact_Text_Y_Offset),
            0,
            20,
            Color.WHITE,
            0,
            true,
            true,
            Color(0, 0, 0, 0),
            Vector2D(),
            false,
            Color.WHITE
        )
    end

    if One_Time_Updates_Data.PassiveEnabled then
        self:DrawText(
            "Passive Mode",
            Viewport.GetViewportSize() - Vector2D(380, 30),
            0,
            14,
            Color.WHITE,
            0,
            true,
            true,
            Color(0, 0, 0, 0),
            Vector2D(),
            false,
            Color.WHITE
        )
    end

    if IsCriminal then
        self:DrawText(
            "Criminal",
            Viewport.GetViewportSize() - Vector2D(380, 30),
            0,
            14,
            Color.RED,
            0,
            true,
            true,
            Color(0, 0, 0, 0),
            Vector2D(),
            false,
            Color.WHITE
        )
    end

    if One_Time_Updates_Data.DisplayedAmmo then
        self:DrawText(
            One_Time_Updates_Data.DisplayedAmmo[1],
            Viewport.GetViewportSize() - Vector2D(400, 85),
            FontType.OpenSans,
            16,
            Color.WHITE,
            0,
            true,
            true,
            Color.TRANSPARENT,
            Vector2D(),
            false,
            Color.BLACK
        )
        self:DrawText(
            One_Time_Updates_Data.DisplayedAmmo[2] .. " / " .. One_Time_Updates_Data.DisplayedAmmo[3],
            Viewport.GetViewportSize() - Vector2D(400, 60),
            FontType.OpenSans,
            20,
            Color.WHITE,
            0,
            true,
            true,
            Color.TRANSPARENT,
            Vector2D(),
            true,
            Color.BLACK
        )
    end
end)
One_Time_Updates_Canvas:Repaint()

function HandlePassiveChange(value)
    One_Time_Updates_Data.PassiveEnabled = value
    One_Time_Updates_Canvas:Repaint()

    --print("HandlePassiveChange", value)

    if AddNotification then
        if value then
            AddNotification("Passive", "Passive Mode Enabled")
        else
            AddNotification("Passive", "Passive Mode Disabled")
        end
    end
end
Events.SubscribeRemote("PassiveModeChangedClient", function(value)
    HandlePassiveChange(value)
end)

function Get3DLocationOnScreen(loc)
    local project = Viewport.ProjectWorldToScreen(loc)
    if (project and project ~= Vector2D(-1, -1)) then
        return project
    end
end

local Waypoint_Canvas = Canvas(
    true,
    Color.TRANSPARENT,
    Waypoint_Render_Interval_ms/1000,
    true
)


Waypoints = {}

Waypoint_Canvas:Subscribe("Update", function(self, width, height)
    --print(Client.GetLocalPlayer():GetCameraLocation())
    for k, v in pairs(Waypoints) do
        local Vector_waypoint = Get3DLocationOnScreen(v[1] + Vector(0, 0, 5))
        if Vector_waypoint then
            self:DrawText(
                v[2],
                Vector_waypoint,
                FontType.OpenSans,
                10,
                Color.WHITE,
                0,
                true,
                true,
                Color(0, 0, 0, 0),
                Vector2D(),
                true,
                Color.BLACK
            )
            self:DrawLine(Vector_waypoint + Vector2D(-25, 10), Vector_waypoint + Vector2D(0, 20), 1, Color(255, 204, 0))
            self:DrawLine(Vector_waypoint + Vector2D(25, 10), Vector_waypoint + Vector2D(0, 20), 1, Color(255, 204, 0))
        end
    end
end)

Timer.SetInterval(function()
    local self_loc = Client.GetLocalPlayer():GetCameraLocation()
    for k, v in pairs(Waypoints) do
        --print(v[1]:Distance(self_loc))
        if (v[1]:DistanceSquared(self_loc) <= Waypoint_Reached_Distance_sq) then
            Events.Call("WaypointReached", k, table.unpack(Waypoints[k]))
            Waypoints[k] = nil
        end
    end
end, Waypoint_Check_Completed_ms)

local last_waypoint_id = 0

function CreateWaypoint(loc, text, ...)
    if (loc and text) then
        last_waypoint_id = last_waypoint_id + 1
        Waypoints[last_waypoint_id] = {loc, text, ...}
        return (last_waypoint_id)
    else
        error("CreateWaypoint wrong arguments")
    end
end

function DestroyWaypoint(waypoint_id)
    if Waypoints[waypoint_id] then
        Waypoints[waypoint_id] = nil
    end
end

--[[Events.Subscribe("WaypointReached", function(...)
    print("WaypointReached", ...)
end)

CreateWaypoint(Vector(70, 1315, 98), "TestWaypoint")]]--

function NeedToUpdateAmmoText(char, weapon)
    One_Time_Updates_Data.DisplayedAmmo = nil
    if char then
        local ply = Client.GetLocalPlayer()
        if ply then
            local local_char = ply:GetControlledCharacter()
            if local_char == char then
                if weapon then
                    local mesh_name = weapon:GetMesh()
                    local split_dsgs = split_str(mesh_name, ":")
                    if split_dsgs[2] then
                        mesh_name = split_dsgs[2]
                    end
                    One_Time_Updates_Data.DisplayedAmmo = {tostring(mesh_name), tostring(weapon:GetAmmoClip()), tostring(weapon:GetAmmoBag())}
                end
            end
        end
    end
    One_Time_Updates_Canvas:Repaint()
end
Character.Subscribe("Fire", NeedToUpdateAmmoText)
Character.Subscribe("Reload", NeedToUpdateAmmoText)
Character.Subscribe("PickUp", NeedToUpdateAmmoText)
Events.SubscribeRemote("NeedUpdateCanvasAmmo", function()
    local ply = Client.GetLocalPlayer()
    if ply then
        local local_char = ply:GetControlledCharacter()
        if local_char then
            NeedToUpdateAmmoText(local_char, local_char:GetPicked())
        end
    end
end)
Character.Subscribe("Drop", function(char)
    local local_player = Client.GetLocalPlayer()
    local local_char = local_player:GetControlledCharacter()
    if local_char then
        if (local_char == char) then
            One_Time_Updates_Data.DisplayedAmmo = nil
            One_Time_Updates_Canvas:Repaint()
        end
    end
end)
Player.Subscribe("Possess", function(ply, char)
	NeedToUpdateAmmoText(char, char:GetPicked())
end)
Player.Subscribe("UnPossess", function(ply, char)
	local local_player = Client.GetLocalPlayer()
    local local_char = local_player:GetControlledCharacter()
    if local_char then
        if (local_char == char) then
            One_Time_Updates_Data.DisplayedAmmo = nil
            One_Time_Updates_Canvas:Repaint()
        end
    end
end)