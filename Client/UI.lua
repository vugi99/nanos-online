
OMoney = nil
OBankMoney = nil


ONLINE_WEBUI = WebUI(
    "Online UI",
    "file://ui/index.html",
    WidgetVisibility.VisibleNotHitTestable
)

Player.Subscribe("Possess", function(ply, char)
	if ply == Client.GetLocalPlayer() then
        ONLINE_WEBUI:CallEvent("UpdateUIHealth", char:GetMaxHealth(), char:GetHealth())
    end
end)

Player.Subscribe("UnPossess", function(ply, char)
	if ply == Client.GetLocalPlayer() then
        ONLINE_WEBUI:CallEvent("HideUIHealth")
    end
end)

Character.Subscribe("HealthChange", function(char, old_health, new_health)
    --print("HealthChange", old_health, new_health)
	local ply = Client.GetLocalPlayer()
    local pchar = ply:GetControlledCharacter()
    if(pchar and (char == pchar)) then
        ONLINE_WEBUI:CallEvent("UpdateUIHealth", char:GetMaxHealth(), new_health)
    end
end)

function PlayWasted(from_client)
    Client.GetLocalPlayer():StartCameraFade(0, 0.95, Online_Respawn_Config.Time_ms / 5000, Color.BLACK, false, true)
    PostProcess.SetChromaticAberration(10)

    local wasted_sound = Sound(
        Vector(),
        "package://" .. Package.GetName() .. "/Client/sounds/wasted.ogg",
        true,
        true,
        SoundType.SFX,
        1,
        1
    )
    if not from_client then
        Timer.SetTimeout(function()
            StopWasted()
        end, Online_Respawn_Config.Time_ms / 3)
    end
end
Events.SubscribeRemote("PlayWasted", PlayWasted)

function StopWasted()
    Client.GetLocalPlayer():StopCameraFade()
    PostProcess.SetChromaticAberration()
end
StopWasted()

Character.Subscribe("Death", function(char, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
	local ply = Client.GetLocalPlayer()
    local pchar = ply:GetControlledCharacter()
    if(pchar and (char == pchar)) then
        PlayWasted(true)
        CloseAllDialogs()
    end
end)


Character.Subscribe("Respawn", function(char)
    local ply = Client.GetLocalPlayer()
    local pchar = ply:GetControlledCharacter()
    if (pchar and (char == pchar)) then
        StopWasted()
    end
end)

Events.SubscribeRemote("UpdateClientOMoney", function(value)
    OMoney = value
    if value ~= nil then
        ONLINE_WEBUI:CallEvent("SetUIMoney", tostring(value) .. "$")
    else
        ONLINE_WEBUI:CallEvent("HideUIMoney")
    end
end)

Events.SubscribeRemote("UpdateClientOBankMoney", function(value)
    OBankMoney = value
    if value ~= nil then
        ONLINE_WEBUI:CallEvent("SetUIBankMoney", tostring(value) .. "$")
    else
        ONLINE_WEBUI:CallEvent("HideUIBankMoney")
    end
end)

ONLINE_REGISTER_KEY("ToggleMouse", "I")

Input.Bind("ToggleMouse", InputEvent.Pressed, function()
    if (IsDialogFree() or (not Input.IsMouseEnabled())) then
        Input.SetMouseEnabled(not Input.IsMouseEnabled())
    end
end)

ONLINE_WEBUI:CallEvent("EnableOnlineLevels")

OLevel = nil
OXP = nil

Events.SubscribeRemote("UpdateClientXP", function(xp)
    OXP = xp
    ONLINE_WEBUI:CallEvent("SetBarPercentage", xp*100/Levels_Function(OLevel))
end)

Events.SubscribeRemote("UpdateClientLevel", function(level)
    OLevel = level
    ONLINE_WEBUI:CallEvent("SetLvlText", tostring(OLevel))
end)