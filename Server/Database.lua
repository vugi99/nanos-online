

PLAYERS_DATA = {}

Online_DB = Database(DatabaseEngine.SQLite, "db=Online.db timeout=2")

function SGetMapForTableName()
    return '"' .. Server.GetMap() .. '"'
end

function InitializeOnlineMapTable()
    local exec_str = 'CREATE TABLE IF NOT EXISTS ' .. SGetMapForTableName() .. " ("
    for i, v in ipairs(Online_Database_Keys) do
        exec_str = exec_str .. v.name .. " " .. v.type .. ", "
    end
    exec_str = string.sub(exec_str, 1, -3)
    exec_str = exec_str .. ")"

    --print(exec_str)

    Online_DB:Execute(exec_str)
end
InitializeOnlineMapTable()

function LoadPlayerData(ply)
    local rows = Online_DB:Select("SELECT * FROM " .. SGetMapForTableName() .. " WHERE steamid = :0", tostring(ply:GetSteamID()))
    PLAYERS_DATA[ply] = {}
    if not rows[1] then
        local insert_str = "INSERT INTO " .. SGetMapForTableName() .. " VALUES (" .. tostring(ply:GetSteamID()) .. ", "
        for i, v in ipairs(Online_Database_Keys) do
            if v.default ~= nil then
                PLAYERS_DATA[ply][v.name] = v.default

                local def_val
                if v.tbl_to_data then
                    --print(NanosTable.Dump(v.default), JSON.stringify(v.default), NanosTable.Dump(JSON.parse("[]")))
                    def_val = v.tbl_to_data(v.default)
                else
                    def_val = tostring(v.default)
                end

                if v.type == "TEXT" then
                    insert_str = insert_str .. "'" .. def_val .. "', "
                else
                    insert_str = insert_str .. def_val .. ', '
                end
            end
        end

        insert_str = string.sub(insert_str, 1, -3)
        insert_str = insert_str .. ")"

        --print(insert_str)

        Online_DB:Execute(insert_str)
    else
        for i, v in ipairs(Online_Database_Keys) do
            if rows[1][v.name] then
                if v.data_to_tbl then
                    PLAYERS_DATA[ply][v.name] = v.data_to_tbl(rows[1][v.name])
                else
                    PLAYERS_DATA[ply][v.name] = rows[1][v.name]
                end
            else
                PLAYERS_DATA[ply][v.name] = v.default
            end
        end
    end

    local interval_id = Timer.SetInterval(function()
        if (ply and ply:IsValid() and PLAYERS_DATA[ply]) then
            SavePlayerData(ply)
        end
    end, Player_Data_Save_Interval_s * 1000)
    Timer.Bind(interval_id, ply)
    --print(NanosTable.Dump(PLAYERS_DATA[ply]))

    Events.Call("PlayerDataLoaded", ply)

    print(ply:GetAccountName() .. " data loaded")
end

function SavePlayerData(ply, left)
    if PLAYERS_DATA[ply] then
        PLAYERS_DATA[ply].playtime = PLAYERS_DATA[ply].playtime + (os.time() - ply:GetValue("JoinTime"))
        ply:SetValue("JoinTime", os.time(), false)

        local update_str = "UPDATE " .. SGetMapForTableName() .. " SET "
        for i, v in ipairs(Online_Database_Keys) do
            if v.default ~= nil then
                if PLAYERS_DATA[ply][v.name] ~= nil then
                    local set_val
                    if v.tbl_to_data then
                        set_val = v.tbl_to_data(PLAYERS_DATA[ply][v.name])
                    else
                        set_val = tostring(PLAYERS_DATA[ply][v.name])
                    end

                    if v.type == "TEXT" then
                        update_str = update_str .. v.name .. "='" .. set_val .. "', "
                    else
                        update_str = update_str .. v.name .. "=" .. set_val .. ', '
                    end
                end
            end
        end

        update_str = string.sub(update_str, 1, -3)
        update_str = update_str .. " WHERE steamid = " .. tostring(ply:GetSteamID())

        --print(update_str)

        --print(NanosTable.Dump(PLAYERS_DATA[ply]))

        Online_DB:Execute(update_str)
        if left then
            PLAYERS_DATA[ply] = nil
        end
    end
end
Player.Subscribe("Destroy", function(ply)
    SavePlayerData(ply, true)
end)
Package.Subscribe("Unload", function()
    for k, v in pairs(Player.GetPairs()) do
        SavePlayerData(v, true)
    end
    Online_DB:Close()
end)

Events.SubscribeRemote("OnlineResetPlayerData", function(ply)
    if (ply and ply:IsValid() and PLAYERS_DATA[ply]) then
        PLAYERS_DATA[ply] = nil
        -- DELETE FROM "Online"."default-blank-map" WHERE  "steamid"='76561197972837186';
        Online_DB:Execute('DELETE FROM ' .. SGetMapForTableName() .. ' WHERE  "steamid"=' .. "'" .. tostring(ply:GetSteamID()) .. "';")

        ply:Kick("Data Reset")
    end
end)