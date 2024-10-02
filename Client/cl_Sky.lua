


Sky.Spawn(true)
Sky.SetAnimateTimeOfDay(true, Sky_Time_Minutes_for_24h/2, Sky_Time_Minutes_for_24h/2)

Events.SubscribeRemote("SyncSkyTime", function(time)
    Sky.SetTimeOfDay(time[1], time[2])
end)

--[[Client.Subscribe("Tick", function(ds)
	print(Sky.GetTimeOfDay())
end)]]--

Events.SubscribeRemote("SetWeatherClient", function(weather, transition_time)
    Sky.ChangeWeather(weather, transition_time)
end)