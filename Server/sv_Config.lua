

Default_Player_Money = 500
Default_Player_Bank_Money = 5000

Player_Data_Save_Interval_s = 900

Player_Character_SpeedMultiplier = 1.2
Player_Character_Capsule_Size = {36, 96}


Online_Database_Keys = {
    {
        name = "steamid",
        type = "VARCHAR(255)",
    },
    {
        name = "money",
        type = "INTEGER",
        default = Default_Player_Money,
    },
    {
        name = "bank_money",
        type = "INTEGER",
        default = Default_Player_Bank_Money,
    },
    {
        name = "skin",
        type = "TEXT",
        default = "",
    },
    {
        name = "energy_bars",
        type = "INTEGER",
        default = 0,
    },
    {
        name = "level",
        type = "INTEGER",
        default = 1,
    },
    {
        name = "xp",
        type = "INTEGER",
        default = 0,
    },
    {
        name = "playtime",
        type = "INTEGER",
        default = 0,
    },
    {
        name = "garages",
        type = "TEXT",
        default = {},
        data_to_tbl = function(value)
            return JSON.parse(value)
        end,
        tbl_to_data = function(value)
            if next(value) == nil then
                return "[]"
            end
            return JSON.stringify(value)
        end,
    },
    {
        name = "passive",
        type = "INTEGER",
        default = false,
        data_to_tbl = function(value)
            return (value == 1)
        end,
        tbl_to_data = function(value)
            if value then
                return 1
            else
                return 0
            end
        end,
    },
    {
        name = "criminal_bonus",
        type = "INTEGER",
        default = 0,
    },
    {
        name = "weapons",
        type = "TEXT",
        default = {},
        data_to_tbl = function(value)
            return JSON.parse(value)
        end,
        tbl_to_data = function(value)
            if next(value) == nil then
                return "[]"
            end
            return JSON.stringify(value)
        end,
    },
    {
        name = "weapons_picked",
        type = "TEXT",
        default = {},
        data_to_tbl = function(value)
            return JSON.parse(value)
        end,
        tbl_to_data = function(value)
            if next(value) == nil then
                return "[]"
            end
            return JSON.stringify(value)
        end,
    },
    {
        name = "ammos",
        type = "TEXT",
        default = {},
        data_to_tbl = function(value)
            return JSON.parse(value)
        end,
        tbl_to_data = function(value)
            if next(value) == nil then
                return "[]"
            end
            return JSON.stringify(value)
        end,
    },
    {
        name = "houses",
        type = "TEXT",
        default = {},
        data_to_tbl = function(value)
            return JSON.parse(value)
        end,
        tbl_to_data = function(value)
            if next(value) == nil then
                return "[]"
            end
            return JSON.stringify(value)
        end,
    },
}


Online_Admins = {
    ["76561197972837186"] = true,
    ["76561198453762859"] = true,
}

ATM_Mesh = "nanos-world::SM_Refrigerator"

Player_Death_Drop_Money_Mult = 0.1
Player_Death_Money_Drop_Lifespan_s = 900

Weather_Rotation_Config = {
    Rotation_Interval_Range_s = {300, 3600},
    Weather_Transition_Time_Range_s = {60, 299},

    Rotation_Weather_Types = {
        {WeatherType.ClearSkies, 0.1},
        {WeatherType.Cloudy, 0.2},
        {WeatherType.Foggy, 0.02},
        {WeatherType.Overcast, 0.1},
        {WeatherType.PartlyCloudy, 0.4},
        {WeatherType.Rain, 0.06},
        {WeatherType.RainLight, 0.1},
        {WeatherType.RainThunderstorm, 0.02},
    }
}

Vendor_Respawn_Time_s = 300

Passive_Change_Cooldown_s = 120

PlayerRegenHealthAfter_ms = 20000
PlayerRegenInterval_ms = 1000
PlayerRegenAddedHealth = 5
PlayerRegenMaxHP = 50


Take_Money_Bag_XP = 50
PolicemanKillCriminal_XP = 500
OtherKillPlayer_XP = 100
BuyVehicle_XP = 250
DestroyVehicle_XP = 50
BuyWeapon_XP = 150
BuyAmmo_XP = 5

PoliceCarSpawnerCooldown_ms = 180*1000

Criminal_Bonus_Increase_Per_Crime = 250
Criminal_Crime_Get_KnownByPolice_After_ms = 20*1000

Vehicle_Hit_Impact_Force_Multiplier_For_Damage = 0.2
Vehicle_Explode_Lifespan_s = 600
Vehicle_Smoke_From_Health_Mult = 0.25

PlayersPlayingOnServer_Reward = {
    Interval_ms = 1200*1000,
    Money = 200,
    XP = 100,
}

Grocery_Heist_Ranges = {
    Money = {200, 1500},
    XP = {50, 500},
}