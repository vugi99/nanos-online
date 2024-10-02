

function CharacterCreationUI(menu_spawn, ...)
    local varargs = table.pack(...)

    local prev_char

    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    local offset = 325
    dialogPosition.top = math.floor((ScreenY - offset) / 2) .. "px"
    dialogPosition.left = math.floor(ScreenX - 700) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Skin Selection")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.setCanClose(false)
    --dialog.onClickClose(function(obj)
        --obj.hide()
    --end)

    local Skin_text = UIText()
    Skin_text.setContent("Please select a skin")
    Skin_text.appendTo(dialog)

    local selectedSkin
    local skinList = UIOptionList()
    for i, v in ipairs(Player_Skins) do
        skinList.appendOption(i-1, v)
    end
    skinList.appendTo(dialog)
    skinList.onChange(function(obj)
        selectedSkin = Player_Skins[obj.getValue()[1]+1]

        if not prev_char then
            prev_char = CharacterSimple(menu_spawn.location + Vector(0, 0, 100), menu_spawn.rotation, selectedSkin)
        else
            prev_char:SetMesh(selectedSkin, false)
        end
    end)

    local okButton = UIButton()
    okButton.setTitle("Select")
    okButton.onClick(function(obj)
        if selectedSkin then
            CloseDialog(dialog)

            prev_char:Destroy()

            Events.CallRemote("SkinChosen", selectedSkin, menu_spawn)

            SelectSpawnUI(table.unpack(varargs))
        end
    end)
    okButton.appendTo(dialog)

    OpenDialog(dialog, true)
end

function SelectSpawnUI(custom_spawns)
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    local offset = 300
    dialogPosition.top = math.floor((ScreenY - offset) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Spawn Selection")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.setCanClose(false)
    --dialog.onClickClose(function(obj)
        --obj.hide()
    --end)

    local Spawn_text = UIText()
    Spawn_text.setContent("Please select a spawn")
    Spawn_text.appendTo(dialog)

    local spawnList = UIOptionList()
    local spawn_index = 0
    local spawns = {}
    for i, v in ipairs(O_PlayerSpawn_C) do
        if v.Big_Spawn then
            spawnList.appendOption(spawn_index, v.Big_Spawn_Name)
            table.insert(spawns, v)
            spawn_index = spawn_index + 1
        end
    end
    for i, v in ipairs(custom_spawns) do
        spawnList.appendOption(spawn_index, v[3])
        table.insert(spawns, v)
        spawn_index = spawn_index + 1
    end
    spawnList.appendTo(dialog)
    spawnList.onChange(function(obj)
        local selectedSpawn = spawns[obj.getValue()[1]+1]

        Events.CallRemote("SelectedSpawn", selectedSpawn)

        CloseDialog(dialog)
    end)

    OpenDialog(dialog, true)
end


Events.SubscribeRemote("SpawnClientUI", function(menu_spawn, character_creation, custom_spawns)
    if character_creation then
        CharacterCreationUI(menu_spawn, custom_spawns)
    else
        SelectSpawnUI(custom_spawns)
    end
end)