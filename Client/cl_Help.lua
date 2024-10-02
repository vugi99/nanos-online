

ONLINE_REGISTER_KEY("Help", "F1")

Chat.AddMessage("Press " .. Input.GetMappedKeys("Help")[1] .. " to open the Help Menu")

function ShowKeysUI()
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 400) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Help Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        CloseDialog(dialog)
    end)

    local Keystext = UIText()
    local text = "Keys : <br> "

    for k, v in pairs(ONLINE_REGISTERED_BINDINGS) do
       text = text .. v .. " : " .. Input.GetMappedKeys(v)[1] .. " <br> "
    end

    Keystext.setContent(text)
    Keystext.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        SelectHelpUI()
    end)
    BackButton.appendTo(dialog)

    OpenDialog(dialog, true)
end

function HelpTextBlockUI(text)
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 350) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Help Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        CloseDialog(dialog)
    end)

    local textblock = UIText()

    textblock.setContent(text)

    textblock.appendTo(dialog)

    local BackButton = UIButton()
    BackButton.setTitle("Back")
    BackButton.onClick(function(obj)
        SelectHelpUI()
    end)
    BackButton.appendTo(dialog)

    OpenDialog(dialog, true)
end


function SelectHelpUI()
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 325) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Help Menu")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        CloseDialog(dialog)
    end)

    local KeysButton = UIButton()
    KeysButton.setTitle("Show Keys")
    KeysButton.onClick(function(obj)
        ShowKeysUI()
    end)
    KeysButton.appendTo(dialog)

    local WhatYouCanDoButton = UIButton()
    WhatYouCanDoButton.setTitle("What you can do in Nanos Online")
    WhatYouCanDoButton.onClick(function(obj)
        HelpTextBlockUI(wycd_text)
    end)
    WhatYouCanDoButton.appendTo(dialog)

    local WinMoneyButton = UIButton()
    WinMoneyButton.setTitle("Ways to earn money")
    WinMoneyButton.onClick(function(obj)
        HelpTextBlockUI(wtem_text)
    end)
    WinMoneyButton.appendTo(dialog)

    local versiontext = UIText()
    versiontext.setContent("Nanos Online " .. tostring(Package.GetVersion()))
    versiontext.appendTo(dialog)

    OpenDialog(dialog, true)
end

Input.Bind("Help", InputEvent.Pressed, function()
    if IsDialogFree() then
        SelectHelpUI()
    end
end)