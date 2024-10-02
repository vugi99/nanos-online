

Player.Subscribe("Destroy", function(ply)
    local character = ply:GetControlledCharacter()
    if (character) then
        character:Destroy()
    end
end)

Character.Subscribe("Death", function(char, last_damage_taken, last_bone_damaged, damage_type_reason, hit_from_direction, instigator, causer)
    --print("Character Death", char, damage_type_reason, instigator, causer)

	local ply = char:GetPlayer()
    if ply then
        local dim = VDimension.GetObjectFromDimension(ply:GetDimension())
        if (dim and dim == DEFAULT_DIMENSION) then
            local p_money = math.floor(PLAYERS_DATA[ply].money * Player_Death_Drop_Money_Mult)
            if p_money > 0 then
                local char_loc = char:GetLocation()
                --print(char:GetCapsuleSize().HalfHeight)
                local money_pickup = VPickup(Vector(char_loc.X, char_loc.Y, char_loc.Z-char:GetCapsuleSize().HalfHeight), char:GetRotation(), "nanos-world::SM_MoneyStack", {"Character"}, function(trigger, ent)
                    if (ent:GetPlayer() and ent:GetHealth() > 0) then
                        OAddMoney(ent:GetPlayer(), p_money)
                        AddPlayerXP(ent:GetPlayer(), Take_Money_Bag_XP)
                        trigger:Destroy()

                        Events.CallRemote("AddNotification", ent:GetPlayer(), "", "You got " .. tostring(p_money) .. "$")
                    end
                end, nil, nil, tostring(p_money) .. "$")
                money_pickup:SetLifeSpan(Player_Death_Money_Drop_Lifespan_s)
                OBuy(ply, p_money)
                Events.CallRemote("AddNotification", ply, "", "You lost " .. tostring(p_money) .. "$")
            end

            if instigator then
                if instigator ~= ply then
                    if (Criminals[ply] and Policemans[instigator]) then
                        OAddMoney(instigator, PLAYERS_DATA[ply].criminal_bonus)
                        AddPlayerXP(instigator, PolicemanKillCriminal_XP)
                        Events.CallRemote("AddNotification", instigator, "Police", "You earned " .. tostring(PLAYERS_DATA[ply].criminal_bonus) .. "$ for killing this criminal")
                        PlayerNoLongerCriminal(ply)
                    else
                        AddPlayerXP(instigator, OtherKillPlayer_XP)
                        AddPlayerCriminalBonus(instigator, 2)
                    end
                end
            end

            Timer.SetTimeout(function()
                if (ply:IsValid() and char:IsValid() and char:GetHealth() <= 0) then
                    local char_loc = char:GetLocation()
                    local nearest_spawns = {}
                    local count = 0
                    local max_count = table_count(Online_Respawn_Config.Smart_Spawns)
                    for i, v in ipairs(O_PlayerSpawn_C) do
                        local inserted = false

                        local dist_sq = char_loc:DistanceSquared(v.location)
                        for i2, v2 in ipairs(nearest_spawns) do
                            if dist_sq < v2.dist_sq then
                                table.insert(nearest_spawns, i2, {dist_sq = dist_sq, spawn = v})
                                if count < max_count then
                                    count = count + 1
                                else
                                    table.remove(nearest_spawns, count + 1)
                                end
                                inserted = true
                                break
                            end
                        end

                        if (not inserted and count < max_count) then
                            table.insert(nearest_spawns, {dist_sq = dist_sq, spawn = v})
                            count = count + 1
                        end
                    end

                    --print(NanosTable.Dump(nearest_spawns))

                    local selected_spawn
                    local s = 0
                    local r = math.random()
                    for i, v in ipairs(Online_Respawn_Config.Smart_Spawns) do
                        s = s + v
                        if r <= s then
                            if nearest_spawns[i] then
                                selected_spawn = nearest_spawns[i].spawn
                            else
                                selected_spawn = nearest_spawns[math.random(table_count(nearest_spawns))].spawn
                            end
                            break
                        end
                    end

                    char:Respawn(selected_spawn.location + Vector(0, 0, 100), selected_spawn.rotation)
                    --char:PlayAnimation("nanos-world::A_Mannequin_Itching_Body")
                end
            end, Online_Respawn_Config.Time_ms)

        else
            local cur_char_loc = char:GetLocation()
            local cur_char_rot = char:GetRotation()
            Timer.SetTimeout(function()
                if (ply:IsValid() and char:IsValid() and char:GetHealth() <= 0) then
                    char:Respawn(cur_char_loc, cur_char_rot)
                end
            end, Online_Respawn_Config.Time_ms)
        end
    elseif char:GetValue("NPCVendor") then
        if instigator then
            AddPlayerCriminalBonus(instigator, 1)
        end
    end
end)

function ClearRegenTimeouts(char)
    if char:IsValid() then
        if char:GetValue("RegenTimeout") then
            Timer.ClearTimeout(char:GetValue("RegenTimeout"))
            char:SetValue("RegenTimeout", nil, false)
        end
        if char:GetValue("RegenInterval") then
            Timer.ClearInterval(char:GetValue("RegenInterval"))
            char:SetValue("RegenInterval", nil, false)
        end
    end
end

Character.Subscribe("TakeDamage", function(char, damage, bone, dtype, from_direction, instigator, causer)
    local ply = char:GetPlayer()
    if ply then
        if PLAYERS_DATA[ply] then
            if PLAYERS_DATA[ply].passive then
                if (dtype == DamageType.Shot or dtype == DamageType.Explosion or dtype == DamageType.Punch or dtype == DamageType.RunOverVehicle or dtype == DamageType.Melee) then
                    return false
                end
            end

            local chealth = char:GetHealth() - damage
            ClearRegenTimeouts(char)
            if (chealth > 0 and chealth < PlayerRegenMaxHP) then
                char:SetValue("RegenTimeout", Timer.SetTimeout(function()
                    --print("RegenTimeout")
                    if char:IsValid() then
                        char:SetValue("RegenTimeout", nil, false)
                        char:SetValue("RegenInterval", Timer.SetInterval(function()
                            if char:IsValid() then
                                if (char:GetHealth() > 0 and char:GetHealth() < PlayerRegenMaxHP) then
                                    --print("RegenInterval")
                                    local new_health = char:GetHealth() + PlayerRegenAddedHealth
                                    local phealth = PlayerRegenMaxHP
                                    if new_health >= phealth then
                                        char:SetHealth(phealth)
                                        Timer.ClearInterval(char:GetValue("RegenInterval"))
                                        char:SetValue("RegenInterval", nil, false)
                                    else
                                        char:SetHealth(new_health)
                                    end
                                else
                                    return false
                                end
                            else
                                return false
                            end
                        end, PlayerRegenInterval_ms), false)
                    end
                end, PlayerRegenHealthAfter_ms), false)
            end
        end
    end
end)

Events.SubscribeRemote("PMPlayAnimation", function(ply, anim_id, loop)
    if (ply and ply:IsValid() and anim_id) then
        local char = ply:GetControlledCharacter()
        if (char and char:IsValid() and char:GetHealth() > 0) then
            if (not char:GetVehicle()) then
                if anim_id == 0 then
                    if char:GetValue("PlayingAnim") then
                        char:StopAnimation(char:GetValue("PlayingAnim"))
                        char:SetValue("PlayingAnim", nil, false)
                    end
                else
                    char:PlayAnimation(Player_Menu_Animations[anim_id], AnimationSlotType.FullBody, loop, 0.1, 0.1, 1.0, true)
                    char:SetValue("PlayingAnim", Player_Menu_Animations[anim_id], false)
                end
            end
        end
    end
end)

function SetPlayerPassive(ply, enable)
    if (ply and PLAYERS_DATA[ply] and (not ply:GetValue("PassiveLocked"))) then
        --print("SetPlayerPassive", ply, enable)
        if enable ~= PLAYERS_DATA[ply].passive then
            PLAYERS_DATA[ply].passive = enable
            local char = ply:GetControlledCharacter()
            if char then
                EquipSlot(char, 4)
            end
            Events.CallRemote("PassiveModeChangedClient", ply, PLAYERS_DATA[ply].passive)
            return true
        end
    end
end

function LockPlayerPassive(ply, lock)
    ply:SetValue("PassiveLocked", lock, false)
end

Events.SubscribeRemote("PMTogglePassive", function(ply)
    if (ply and PLAYERS_DATA[ply]) then
        if not ply:GetValue("PassiveCooldownTimer") then
            local set = SetPlayerPassive(ply, not PLAYERS_DATA[ply].passive)
            if set then
                ply:SetValue("PassiveCooldownTimer", Timer.SetTimeout(function()
                    if ply:IsValid() then
                        ply:SetValue("PassiveCooldownTimer", nil, false)
                    end
                end, Passive_Change_Cooldown_s * 1000), false)
            else
                Events.CallRemote("AddNotification", ply, "Passive", "Cannot enable passive now")
            end
        else
            Events.CallRemote("AddNotification", ply, "Passive", "Cannot enable passive now")
        end
    end
end)

Events.Subscribe("PlayerDataLoaded", function(ply)
    Events.CallRemote("PassiveModeChangedClient", ply, PLAYERS_DATA[ply].passive)
    ply:SetValue("PassiveLocked", false, false)
    ply:SetValue("JoinTime", os.time(), false)
end)

Package.Subscribe("Unload", function()
    for k, v in pairs(Player.GetPairs()) do
        if v:GetValue("PassiveCooldownTimer") then
            Timer.ClearTimeout(v:GetValue("PassiveCooldownTimer"))
            v:SetValue("PassiveCooldownTimer", nil, false)
        end
    end
end)

Events.SubscribeRemote("AskPlaytime", function(ply)
    if (ply and ply:IsValid() and PLAYERS_DATA[ply]) then
        PLAYERS_DATA[ply].playtime = PLAYERS_DATA[ply].playtime + (os.time() - ply:GetValue("JoinTime"))
        ply:SetValue("JoinTime", os.time(), false)
        Events.CallRemote("ClientPlaytime", ply, PLAYERS_DATA[ply].playtime)
    end
end)

Timer.SetInterval(function()
    for k, v in pairs(Player.GetPairs()) do
        if PLAYERS_DATA[v] then
            OAddMoney(v, PlayersPlayingOnServer_Reward.Money)
            AddPlayerXP(v, PlayersPlayingOnServer_Reward.XP)
        end
    end
    Events.BroadcastRemote("AddNotification", "Server", "You won " .. tostring(PlayersPlayingOnServer_Reward.Money) .. "$ and " .. tostring(PlayersPlayingOnServer_Reward.XP) .. " XP for playing on the server", 10000)
end, PlayersPlayingOnServer_Reward.Interval_ms)