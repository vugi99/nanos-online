
Package.Require("Sh_Config.lua")
Package.Require("cl_Config.lua")
Package.Require("Sh_Funcs.lua")
Package.Require("Sh_Pickups.lua")

Input.SetInputEnabled(false)

local Packages_Loaded = false
local _CallOnline_Loaded_Event = false

Package.Subscribe("Load", function()
    Packages_Loaded = true
    if _CallOnline_Loaded_Event then
        Events.Call("ONLINE_CLIENT_GAMEMODE_LOADED")
    end

    print("Online " .. Package.GetVersion() .. " Loaded")
end)

Events.SubscribeRemote("LoadOnlineMapConfig", function(MAP_CONFIG)
    --print("LoadOnlineMapConfig")

    for k, v in pairs(MAP_CONFIG) do
        _ENV[k] = v
    end

    Package.Require("cl_DialogManager.lua")
    Package.Require("UI.lua")
    Package.Require("cl_Spawn.lua")
    Package.Require("cl_Admin.lua")
    Package.Require("cl_Interact.lua")
    Package.Require("Canvas.lua")
    Package.Require("cl_Atm.lua")
    Package.Require("cl_Pickups.lua")
    Package.Require("Notifications.lua")
    Package.Require("cl_Sky.lua")
    Package.Require("cl_Grocery.lua")
    Package.Require("cl_Player_Menu.lua")
    Package.Require("Nametags.lua")
    Package.Require("cl_Help.lua")
    Package.Require("cl_Police.lua")
    Package.Require("cl_Criminal.lua")
    Package.Require("cl_Garage.lua")
    Package.Require("cl_Car_Dealer.lua")
    Package.Require("cl_Vehicle.lua")
    Package.Require("cl_Gunshop.lua")
    Package.Require("cl_Inventory.lua")
    Package.Require("cl_House.lua")
    Package.Require("cl_Tab.lua")

    if Packages_Loaded then
        Events.Call("ONLINE_CLIENT_GAMEMODE_LOADED")
    else
        _CallOnline_Loaded_Event = true
    end
end)

Chat.Clear()


if Send_Errors_To_Server then
    Console.Subscribe("LogEntry", function(text, type)
        if (type == LogType.Error or type == LogType.Fatal or type == LogType.ScriptingError) then
            Events.CallRemote("LogErrorFromClientONLINE", text, type)
        end
    end)
end

ONLINE_REGISTERED_BINDINGS = {}

function ONLINE_REGISTER_KEY(binding, default_key)
    table.insert(ONLINE_REGISTERED_BINDINGS, binding)
    return Input.Register(binding, default_key)
end