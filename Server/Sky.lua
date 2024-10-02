

local SKY_TIME = {12, 0}
local Current_Weather = nil

Server.Subscribe("Tick", function(ds)
	SKY_TIME[2] = SKY_TIME[2] + ((ds*24*60)/Sky_Time_Minutes_for_24h) /60 -- Conversion to minutes
    while SKY_TIME[2] >= 60 do
        SKY_TIME[1] = SKY_TIME[1] + 1
        SKY_TIME[2] = SKY_TIME[2] - 60
    end

    while SKY_TIME[1] >= 24 do
        SKY_TIME[1] = SKY_TIME[1] - 24
    end

    --print(SKY_TIME[1], SKY_TIME[2])
end)


Events.Subscribe("PlayerDataLoaded", function(ply)
    Events.CallRemote("SyncSkyTime", ply, SKY_TIME)
    Events.CallRemote("SetWeatherClient", ply, Current_Weather, 1)
end)

function SelectWeather()
    Current_Weather = nil

    local r = math.random()
    local s = 0
    for i, v in ipairs(Weather_Rotation_Config.Rotation_Weather_Types) do
        s = s + v[2]
        if r <= s then
            Current_Weather = v[1]
            break
        end
    end
    if not Current_Weather then
        Current_Weather = Weather_Rotation_Config.Rotation_Weather_Types[math.random(table_count(Weather_Rotation_Config.Rotation_Weather_Types))]
    end

    local transition_time = math.random(Weather_Rotation_Config.Weather_Transition_Time_Range_s[1], Weather_Rotation_Config.Weather_Transition_Time_Range_s[2])
    Events.BroadcastRemote("SetWeatherClient", Current_Weather, transition_time)

    Timer.SetTimeout(SelectWeather, math.random(Weather_Rotation_Config.Rotation_Interval_Range_s[1], Weather_Rotation_Config.Rotation_Interval_Range_s[2]) * 1000)

    --print("Selected", Current_Weather)
end
SelectWeather()