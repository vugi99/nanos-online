
ONLINE_REGISTER_KEY("PoliceMenu", "P")
IsPoliceman = false

local tracking_player_name = nil
local tracking_waypoint

function PoliceRecruitmentUI()
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Police")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        CloseDialog(dialog)
    end)

    local Policetext = UIText()
    Policetext.setContent("As a Policeman you earn money by stopping criminals.")
    Policetext.appendTo(dialog)

    local JoinPoliceButton = UIButton()
    JoinPoliceButton.setTitle("Join Police")
    JoinPoliceButton.onClick(function(obj)
        CloseDialog(dialog)
        Events.CallRemote("JoinPolice")
    end)
    JoinPoliceButton.appendTo(dialog)

    OpenDialog(dialog, true)
end


function PoliceUI()
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Police Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        CloseDialog(dialog)
    end)

    if tracking_player_name then
        local TrackingText = UIText()
        TrackingText.setContent("Tracking " .. tracking_player_name)
        TrackingText.appendTo(dialog)
    end

    local CriminalsButton = UIButton()
    CriminalsButton.setTitle("Show criminals")
    CriminalsButton.onClick(function(obj)
        CloseDialog(dialog)
        Events.CallRemote("GetCriminalsForPoliceMenu")
    end)
    CriminalsButton.appendTo(dialog)

    local LeavePoliceButton = UIButton()
    LeavePoliceButton.setTitle("Leave Police")
    LeavePoliceButton.onClick(function(obj)
        CloseDialog(dialog)
        Events.CallRemote("LeavePolice")
    end)
    LeavePoliceButton.appendTo(dialog)

    OpenDialog(dialog, true)
end

local function GetCriminalsTextFromTbl(criminals, index)
    local text = "Name <br> "
    local text2 = "Kill Bonus <br> "
    local text3 = "Level <br> "

    for i, v in ipairs(criminals[index]) do
        text = text .. v.name .. " <br> <br> "
        text2 = text2 .. v.criminal_bonus .. " <br> <br> "
        text3 = text3 .. v.level .. " <br> <br> "
    end
    return text, text2, text3
end

local function UpdateTrackButtons(dialog, comboContainer_Buttons, buttons, criminals, index)
    local count = table_count(criminals[index])
    local b_count = table_count(buttons)

    for i = (count + 1), b_count do
        buttons[i].destroy()
        buttons[i] = nil
    end

    for i = (b_count + 1), count do

        local ButtonCss = UICSS()
        ButtonCss.height = "34px"
        ButtonCss.position = "inherit"

        local TrackButton = UIButton()
        TrackButton.setTitle("Track")
        TrackButton.setCSS(ButtonCss)
        TrackButton.appendTo(comboContainer_Buttons)
        buttons[i] = TrackButton
    end

    for i = 1, count do
        buttons[i].onClick(function(obj)
            CloseDialog(dialog)
            Events.CallRemote("TrackCriminal", criminals[index][i].ply)
        end)
    end
end

function CriminalsUI(criminals)
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = "50px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Police Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        CloseDialog(dialog)
    end)

    local comboContainer = UIContainer()
    comboContainer.setSizes({100,300})
    comboContainer.setDirection("horizontal")
    comboContainer.appendTo(dialog)

    local text, text2, text3 = GetCriminalsTextFromTbl(criminals, 1)
    local Criminalstext = UIText()
    Criminalstext.setContent(text)
    Criminalstext.appendTo(comboContainer)

    local Criminalstext2 = UIText()
    Criminalstext2.setContent(text2)
    Criminalstext2.appendTo(comboContainer)

    local Criminalstext3 = UIText()
    Criminalstext3.setContent(text3)
    Criminalstext3.appendTo(comboContainer)

    local track_buttons = {}
    local comboContainer_Buttons = UIContainer()
    local tbl_index = 1

    comboContainer_Buttons.setSizes({34, 300})
    comboContainer_Buttons.setDirection("vertical")
    comboContainer_Buttons.appendTo(comboContainer)

    local _EmptyText = UIText()
    _EmptyText.setContent("")
    _EmptyText.appendTo(comboContainer_Buttons)

    UpdateTrackButtons(dialog, comboContainer_Buttons, track_buttons, criminals, tbl_index)

    local count = table_count(criminals)
    if count > 1 then
        local OldButton = UIButton()
        local old_button_showed = false
        local next_button_showed = true

        local NextButton = UIButton()
        NextButton.setTitle("Next Page")
        NextButton.onClick(function(obj)
            if next_button_showed then
                tbl_index = tbl_index + 1
                local text, text2, text3 = GetCriminalsTextFromTbl(criminals, tbl_index)
                Criminalstext.setContent(text)
                Criminalstext.update()
                Criminalstext2.setContent(text2)
                Criminalstext2.update()
                Criminalstext3.setContent(text3)
                Criminalstext3.update()
                if count <= tbl_index then
                    next_button_showed = false
                    --obj.hide()
                end
                if not old_button_showed then
                    --OldButton.show()
                    old_button_showed = true
                end
                UpdateTrackButtons(dialog, comboContainer_Buttons, track_buttons, criminals, tbl_index)
            else
                Chat.AddMessage("Can't go at the next page")
            end
        end)
        NextButton.appendTo(dialog)

        OldButton.setTitle("Old Page")
        OldButton.onClick(function(obj)
            if old_button_showed then
                tbl_index = tbl_index - 1
                local text, text2, text3 = GetCriminalsTextFromTbl(criminals, tbl_index)
                Criminalstext.setContent(text)
                Criminalstext.update()
                Criminalstext2.setContent(text2)
                Criminalstext2.update()
                Criminalstext3.setContent(text3)
                Criminalstext3.update()
                if tbl_index == 1 then
                    old_button_showed = false
                    --obj.hide()
                end
                if not next_button_showed then
                    --NextButton.show()
                    next_button_showed = true
                end
                UpdateTrackButtons(dialog, comboContainer_Buttons, track_buttons, criminals, tbl_index)
            else
                Chat.AddMessage("Can't go at the old page")
            end
        end)
        OldButton.appendTo(dialog)
        OldButton.hide()
    end

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        PoliceUI()
    end)
    BackButton.appendTo(dialog)

    OpenDialog(dialog, true)
end
Events.SubscribeRemote("ReceiveCriminalsForUI", CriminalsUI)

RegisterInteract("OnPoliceRecruiterInteract", "PoliceRecruiter", function(ent) return "Interact with Police Recruiter" end, function(ent) return ent:GetHealth() > 0 end)

Events.Subscribe("OnPoliceRecruiterInteract", function(char)
    if not IsPoliceman then
        if not IsCriminal then
            ResetCanInteractWith()
            PoliceRecruitmentUI()
        else
            Events.CallRemote("PoliceArrestCriminal")
        end
    end
end)

Events.SubscribeRemote("PoliceChangedClient", function(value)
    IsPoliceman = value
    if IsPoliceman then
        AddNotification("Police", "You are now a Policeman, press " .. Input.GetMappedKeys("PoliceMenu")[1] .. " to open Police Menu")
    else
        AddNotification("Police", "You are no longer a Policeman", 10000)
    end
end)

Input.Bind("PoliceMenu", InputEvent.Pressed, function()
    if IsDialogFree() then
        if IsPoliceman then
            PoliceUI()
        end
    end
end)

if O_Police_Car_Spawner_C then
    for i, v in ipairs(O_Police_Car_Spawner_C) do
        local trigger = VTrigger(v.location, v.rotation, Vector(400, 200, 200), TriggerType.Box, ONLINE_DEV_IsModeEnabled("TRIGGERS_DEBUG"), Color.RED, {"Character"})
        trigger:SetValue("PoliceCarSpawner", i)
    end
end

RegisterVTriggerInteract("OnPoliceCarSpawnerInteract", "PoliceCarSpawner", function(trigger) return "Spawn Police Car" end, function(trigger) return IsPoliceman end)

Events.Subscribe("OnPoliceCarSpawnerInteract", function(trigger)
    if IsPoliceman then
        ResetCanInteractWith()
        setmetatable(trigger, VTrigger.prototype)
        Events.CallRemote("SpawnPoliceCar", trigger:GetValue("PoliceCarSpawner"))
    end
end)


Events.SubscribeRemote("CriminalTrackingUpdate", function(loc)
    if IsPoliceman then
        if tracking_waypoint then
            DestroyWaypoint(tracking_waypoint)
        end
        if tracking_player_name then
            tracking_waypoint = CreateWaypoint(loc, tracking_player_name .. " crime")

            AddNotification("Police", "New " .. tracking_player_name .. " crime")
        end
    end
end)

Events.SubscribeRemote("StopTracking", function()
    if tracking_waypoint then
        if tracking_player_name then
            AddNotification("Police", "No longer tracking " .. tracking_player_name)
        end
        DestroyWaypoint(tracking_waypoint)
    end
end)

Events.SubscribeRemote("StartTracking", function(name, loc)
    tracking_player_name = name
    AddNotification("Police", "Started tracking " .. name .. " crimes", 10000)
    if loc then
        if tracking_waypoint then
            DestroyWaypoint(tracking_waypoint)
        end
        tracking_waypoint = CreateWaypoint(loc, tracking_player_name .. " crime")
    else
        AddNotification("Police", "No know crime location for now")
    end
end)