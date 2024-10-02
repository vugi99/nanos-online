
Package.Require("Sh_Config.lua")
Package.Require("sv_Config.lua")
Package.Require("Sh_Funcs.lua")
Package.Require("Sh_Pickups.lua")


MAP_CONFIG_LOADED = false
MAP_CONFIG_TO_SEND =  {}



Events.Subscribe("ONLINE_MAP_CONFIG", function(...)
    if not MAP_CONFIG_LOADED then
        local args = table.pack(...)
        for i = 1, args.n do
            local v = args[i]
            MAP_CONFIG_TO_SEND[v.name] = v.data
            _ENV[v.name] = v.data
        end

        MAP_CONFIG_LOADED = true

        LoadServerFiles()

        print("Online : Map Config Loaded")
    else
        Console.Warn("Online : Trying to load another map config while a map config is already loaded")
    end
end)

function LoadServerFiles()
    --print("LoadServerFiles()")

    Package.Require("Dimensions.lua")
    Package.Require("Database.lua")
    Package.Require("Spawn.lua")
    Package.Require("Player.lua")
    Package.Require("Money.lua")
    Package.Require("Admin.lua")
    Package.Require("Pickups.lua")
    Package.Require("Sky.lua")
    Package.Require("Vendors.lua")
    Package.Require("Grocery.lua")
    Package.Require("Levels.lua")
    Package.Require("Police.lua")
    Package.Require("Vehicle.lua")
    Package.Require("Criminal.lua")
    Package.Require("Garage.lua")
    Package.Require("Car_Dealer.lua")
    Package.Require("Gunshop.lua")
    Package.Require("Inventory.lua")
    Package.Require("House.lua")
    Package.Require("Tab.lua")
    Package.Require("Chat.lua")

    Events.Call("ONLINE_GAMEMODE_LOADED")
end

if not MAP_CONFIG_LOADED then
    local map_path = Server.GetMap()
    if map_path then
        local map_path_in_maps = "Server/Maps/" .. map_path .. ".lua"
        local map_files = Package.GetFiles("Server/Maps", ".lua")
        for i, v in ipairs(map_files) do
            if v == map_path_in_maps then
                Package.Require(v)
                break
            end
        end
    end
end

Package.Subscribe("Load", function()
    print("Online " .. Package.GetVersion() .. " Loaded")
end)

if Send_Errors_To_Server then
    Events.SubscribeRemote("LogErrorFromClientONLINE", function(ply, text, logtype)
        local logtype_name = "Unknown"
        for k, v in pairs(LogType) do
            if v == logtype then
                logtype_name = k
            end
        end

        print("Received error log from client", ply:GetID(), ply:GetAccountName(), logtype_name, text)
    end)
end