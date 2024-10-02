

local Menu_Spawns_Count = table_count(O_Menu_Spawn_Char_C)

function CreatePlayerCharacter(ply, loc, rot, dimension)
    local char = Character(loc, rot, PLAYERS_DATA[ply].skin)
    char:SetDimension(dimension)
    char:SetSpeedMultiplier(Player_Character_SpeedMultiplier)
    char:SetCapsuleSize(table.unpack(Player_Character_Capsule_Size))
    char:SetCanDrop(false)

    Events.Call("OnlineSpawnedPlayerCharacter", ply, char)
    return char
end

function HandlePlayerJoin(ply)
    Events.CallRemote("LoadOnlineMapConfig", ply, MAP_CONFIG_TO_SEND)

    LoadPlayerData(ply)



    local random_menu_spawn = O_Menu_Spawn_Char_C[math.random(Menu_Spawns_Count)]
    local camera_menu_spawn = SearchMapDataFirst(O_Menu_Spawn_Camera_C, "Menu_Spawn_ID", random_menu_spawn.Menu_Spawn_ID)

    if camera_menu_spawn then
        local dim = VDimension.Create("Spawn", true)
        ply:SetDimension(dim.ID)

        ply:SetCameraLocation(camera_menu_spawn.location)
        ply:SetCameraRotation(camera_menu_spawn.rotation)

        local custom_spawns = {}
        if (O_Garage_Entry_C and O_Garage_Exit_C) then
            if PLAYERS_DATA[ply].garages.data then
                for i, v in ipairs(PLAYERS_DATA[ply].garages.data) do
                    table.insert(custom_spawns, {"GARAGE_SPAWN", v.garage_id, "Garage " .. tostring(v.garage_id)})
                end
            end
        end

        if (O_House_Entry_C and O_House_Exit_C) then
            for i, v in ipairs(PLAYERS_DATA[ply].houses) do
                table.insert(custom_spawns, {"HOUSE_SPAWN", v.house_id, "House " .. tostring(v.house_id)})
            end
        end

        Events.CallRemote("SpawnClientUI", ply, random_menu_spawn, PLAYERS_DATA[ply].skin == "", custom_spawns)

        if PLAYERS_DATA[ply].skin ~= "" then
            CreatePlayerCharacter(ply, random_menu_spawn.location + Vector(0, 0, 100), random_menu_spawn.rotation, dim.ID)
        end
    else
        Console.Error("Online : Missing camera_menu_spawn for spawn " .. tostring(random_menu_spawn.Menu_Spawn_ID))
    end

    ply:SetVOIPSetting(VOIPSetting.Local)

    --local new_character = Character(Vector(0, 0, 0), Rotator(0, 0, 0), "nanos-world::SK_Male")
    --ply:Possess(new_character)

    --[[local cube = Prop(Vector(0, 0, 150), Rotator(), "nanos-world::SM_Cube")
    local cube2 = Prop(Vector(1000, 0, 500), Rotator(), "nanos-world::SM_Cube")
    local weap = NanosWorldWeapons.AK47()

    new_character:PickUp(weap)

    local dim = VDimension.Create("test2", true)
    ply:SetDimension(dim.ID)
    cube2:SetDimension(dim.ID)

    Timer.SetTimeout(function()
        ply:SetDimension(DEFAULT_DIMENSION.ID)
        --print(cube:GetDimension(), ply:GetDimension())
    end, 5000)]]--
end
Player.Subscribe("Spawn", HandlePlayerJoin)
Events.Subscribe("ONLINE_GAMEMODE_LOADED", function()
    for k, ply in pairs(Player.GetPairs()) do
        HandlePlayerJoin(ply)
    end
end)

Events.SubscribeRemote("SkinChosen", function(ply, skin, menu_spawn)
    if (ply:IsValid() and PLAYERS_DATA[ply]) then
        local dim = VDimension.GetObjectFromDimension(ply:GetDimension())
        if (dim and dim:GetName() == "Spawn") then
            PLAYERS_DATA[ply].skin = skin

            if menu_spawn then
                CreatePlayerCharacter(ply, menu_spawn.location + Vector(0, 0, 100), menu_spawn.rotation, dim.ID)
            end
        end
    end
end)

Events.SubscribeRemote("SelectedSpawn", function(ply, spawn)
    if (ply:IsValid() and PLAYERS_DATA[ply]) then
        local dim = VDimension.GetObjectFromDimension(ply:GetDimension())
        if (dim and dim:GetName() == "Spawn") then
            local chars = dim:GetEntitiesOfClass("Character")
            local char = GetFirstKey(chars)
            if char then
                ply:Possess(char)

                if (not spawn[1]) then
                    char:SetLocation(spawn.location + Vector(0, 0, 100))
                    char:SetRotation(Rotator(0, spawn.rotation.Yaw, 0))

                    ply:SetDimension(DEFAULT_DIMENSION.ID)
                elseif spawn[1] == "GARAGE_SPAWN" then
                    PlayerEnterGarage(ply, spawn[2])
                elseif spawn[1] == "HOUSE_SPAWN" then
                    PlayerEnterHouse(ply, spawn[2])
                end
            else
                Console.Error("Online : Cannot find character to spawn")
            end
        end
    end
end)