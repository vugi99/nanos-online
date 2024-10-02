


local PlayTimeText
local PM_EB_Text

function ConvertPlayTimeToString(online_playtime)
    local days = math.floor(online_playtime / 86400)
    local hours = math.floor((online_playtime - (days * 86400)) / 3600)
    local minutes = math.floor((online_playtime - (days * 86400) - (hours * 3600)) / 60)
    local seconds = online_playtime - (days * 86400) - (hours * 3600) - (minutes * 60)
    return "Playtime : " .. tostring(days) .. " days, " .. tostring(hours) .. " hours, " .. tostring(minutes) .. " mins, " .. tostring(seconds) .. " s."
 end


function AnimationsUI()
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 450) / 2) .. "px"
    dialogPosition.left = math.floor(ScreenX - 700) .. "px !important"
    dialogPosition.width = "600px"

    local selected_anim

    local dialog = UIDialog()
    dialog.setTitle("Animations Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        CloseDialog(dialog)
    end)

    local Anim_text = UIText()
    Anim_text.setContent("Please select an animation")
    Anim_text.appendTo(dialog)

    local loop_anims = false

    local LoopAnimsButton = UICheckBox()
    LoopAnimsButton.setTitle("Loop Animations")
    LoopAnimsButton.setValue(loop_anims)
    LoopAnimsButton.onClick(function(obj)
        loop_anims = not loop_anims
    end)
    LoopAnimsButton.appendTo(dialog)

    local AnimationsList = UIOptionList()
    for i, v in pairs(Player_Menu_Animations) do
        AnimationsList.appendOption(i - 1, v)
    end
    AnimationsList.appendTo(dialog)
    AnimationsList.onChange(function(obj)
        selected_anim = obj.getValue()[1] + 1
        Events.CallRemote("PMPlayAnimation", selected_anim, loop_anims)
    end)

    local StopButton = UIButton()
    StopButton.setTitle("Stop Animations")
    StopButton.onClick(function(obj)
        Events.CallRemote("PMPlayAnimation", 0)
    end)
    StopButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        PlayerMenuUI()
    end)
    BackButton.appendTo(dialog)

    OpenDialog(dialog, true)
end

function ResetDataUI()
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

    local Anim_text = UIText()
    Anim_text.setContent('<p style="color:#FF0000";>WARNING : PRESSING THE BUTTON BELOW WILL RESET YOUR DATA ON THE SERVER</p>')
    Anim_text.appendTo(dialog)

    local ResetButton = UIButton()
    ResetButton.setTitle("RESET DATA")
    ResetButton.onClick(function(obj)
        CloseDialog(dialog)
        Events.CallRemote("OnlineResetPlayerData")
    end)
    ResetButton.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        PlayerMenuUI()
    end)
    BackButton.appendTo(dialog)

    OpenDialog(dialog, true)
end

local function PMGetEBText()
    return "Eat an energy bar (" .. tostring(Client.GetLocalPlayer():GetValue("EnergyBars")) .. " in inventory, will restore " .. tostring(Energy_Bar_Restored_Health) .. " HP)"
end

function PlayerMenuUI()
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
        PlayTimeText = nil
        PM_EB_Text = nil
        CloseDialog(dialog)
    end)

    local PassiveButton = UIButton()
    PassiveButton.setTitle("Toggle Passive")
    PassiveButton.onClick(function(obj)
        Events.CallRemote("PMTogglePassive")
    end)
    PassiveButton.appendTo(dialog)

    --[[local FriendsButton = UIButton()
    FriendsButton.setTitle("Friends")
    FriendsButton.onClick(function(obj)
        --Events.CallRemote("GetFriendsForPlayerMenu")
    end)
    FriendsButton.appendTo(dialog)]]--

    local AnimationsButton = UIButton()
    AnimationsButton.setTitle("Animations Menu")
    AnimationsButton.onClick(function(obj)
        PlayTimeText = nil
        PM_EB_Text = nil
        AnimationsUI()
    end)
    AnimationsButton.appendTo(dialog)

    local Eat_Energy_barButton = UIButton()
    Eat_Energy_barButton.setTitle(PMGetEBText())
    PM_EB_Text = Eat_Energy_barButton
    Eat_Energy_barButton.onClick(function(obj)
        if (Client.GetLocalPlayer():GetValue("EnergyBars") and Client.GetLocalPlayer():GetValue("EnergyBars") > 0) then
            local char = Client.GetLocalPlayer():GetControlledCharacter()
            if (char and char:IsValid()) then
                if (char:GetHealth() < 100 and char:GetHealth() > 0) then
                    AddNotification("Grocery Store", "You ate an energy bar")
                    Events.CallRemote("EatEnergyBar")
                else
                    Chat.AddMessage("You can't eat an energy bar")
                end
            end
        else
            Chat.AddMessage("You don't have energy bars")
        end
    end)
    Eat_Energy_barButton.appendTo(dialog)

    local ResetDataButton = UIButton()
    ResetDataButton.setTitle("Reset Data")
    ResetDataButton.onClick(function(obj)
        PlayTimeText = nil
        PM_EB_Text = nil
        ResetDataUI()
    end)
    ResetDataButton.appendTo(dialog)

    local Play_text = UIText()
    Play_text.setContent(ConvertPlayTimeToString(0))
    Play_text.appendTo(dialog)
    PlayTimeText = Play_text

    Events.CallRemote("AskPlaytime")

    OpenDialog(dialog, true)
end



ONLINE_REGISTER_KEY("PlayerMenu", "F2")

Input.Bind("PlayerMenu", InputEvent.Pressed, function()
    local ply = Client.GetLocalPlayer()
    if ply then
        local char = ply:GetControlledCharacter()
        if char then
            if char:GetHealth() > 0 then
                if IsDialogFree() then
                    PlayerMenuUI()
                end
            end
        end
    end
end)

Player.Subscribe("ValueChange", function(ply, key, value)
    if ply == Client.GetLocalPlayer() then
        if key == "EnergyBars" then
            if value ~= nil then
                if PM_EB_Text then
                    PM_EB_Text.setTitle(PMGetEBText())
                    PM_EB_Text.update()
                end
            end
        end
    end
end)

Events.SubscribeRemote("ClientPlaytime", function(ptime)
    if PlayTimeText then
        PlayTimeText.setContent(ConvertPlayTimeToString(ptime))
        PlayTimeText.update()
    end
end)