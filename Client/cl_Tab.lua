

local _tab_dialog

ONLINE_REGISTER_KEY("Tab", "Tab")

local function UpdateTexts(tbl, tblid, texts)
    for i, v in ipairs(TAB_BUILD) do
        texts[v.key].setContent(v.top .. " <br> ")
        for i2, v2 in ipairs(tbl[tblid]) do
            texts[v.key].setContent(texts[v.key].getContent() .. tostring(v2[v.key]) .. " <br> ")
        end
        texts[v.key].update()
    end
end

Events.SubscribeRemote("TabResponse", function(tbl)
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = "50px"
    dialogPosition.left = math.floor(50) .. "px !important"
    dialogPosition.width = ScreenX - 100 .. "px"

    local dialog = UIDialog()
    dialog.setTitle("Tab")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.setCanClose(false)
    _tab_dialog = dialog

    local comboContainer = UIContainer()
    comboContainer.setSizes({100,1000})
    comboContainer.setDirection("horizontal")
    comboContainer.appendTo(dialog)

    if TAB_BUILD then

        local texts = {}

        for i, v in ipairs(TAB_BUILD) do
            texts[v.key] = UIText()
            texts[v.key].setContent("")
            texts[v.key].appendTo(comboContainer)
        end


        UpdateTexts(tbl, 1, texts)

        local count = table_count(tbl)
        if count > 1 then
            local tbl_index = 1
            local OldButton = UIButton()
            local old_button_showed = false
            local next_button_showed = true
            local NextButton = UIButton()
            NextButton.setTitle("Next Page")
            NextButton.onClick(function(obj)
                tbl_index = tbl_index + 1
                UpdateTexts(tbl, tbl_index, texts)
                if count <= tbl_index then
                    next_button_showed = false
                    obj.hide()
                end
                if not old_button_showed then
                    OldButton.show()
                    old_button_showed = true
                end
                dialog.update()
            end)
            NextButton.appendTo(dialog)

            OldButton.setTitle("Old Page")
            OldButton.onClick(function(obj)
                tbl_index = tbl_index - 1
                UpdateTexts(tbl, tbl_index, texts)
                if tbl_index == 1 then
                    old_button_showed = false
                    obj.hide()
                end
                if not next_button_showed then
                    NextButton.show()
                    next_button_showed = true
                end
                dialog.update()
            end)
            OldButton.appendTo(dialog)
            OldButton.hide()
        end
    end
end)

Input.Bind("Tab", InputEvent.Pressed, function()
    if IsDialogFree() then
        if _tab_dialog then
            _tab_dialog.destroy()
            _tab_dialog = nil
        end
        Events.CallRemote("AskTab")
    end
end)

Input.Bind("Tab", InputEvent.Released, function()
    if _tab_dialog then
        _tab_dialog.destroy()
        _tab_dialog = nil
    end
end)