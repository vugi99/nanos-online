



PlayersCharactersWeapons = {}


function GetCharacterInventory(char)
    for i, v in ipairs(PlayersCharactersWeapons) do
        if v.char == char then
            return i
        end
    end
    return false
end

function GetPlayerInventoryTable(ply)
    local char = ply:GetControlledCharacter()
    if char then
        for i, v in ipairs(PlayersCharactersWeapons) do
            if v.char == char then
                return v
            end
        end
    end
end

function GenerateWeaponToInsert(weapon_name, ammo_bag, slot, ammo_clip)
    return {
        ammo_bag = ammo_bag,
        ammo_clip = ammo_clip,
        weapon_name = weapon_name,
        slot = slot,
    }
end

local function GiveInventoryPlayerWeapon(char, charInvID, i, v)
    local ply = char:GetPlayer()

    if (ply and PLAYERS_DATA[ply]) then
        --print("GiveInventoryPlayerWeapon", char, charInvID, i, NanosUtils.Dump(v))
        local weapon = Online_Weapons[v.weapon_name].func(Vector(), Rotator())
        weapon:SetDimension(char:GetDimension())
        weapon:SetValue("WeaponName", v.weapon_name, false)

        local ammo_type = Online_Weapons[v.weapon_name].ammo_type

        if not PLAYERS_DATA[ply].ammos[ammo_type] then
            PLAYERS_DATA[ply].ammos[ammo_type] = 0
        end

        if (v.ammo_clip and PLAYERS_DATA[ply].ammos[ammo_type] > v.ammo_clip) then
            weapon:SetAmmoClip(v.ammo_clip)
        else
            local clip = weapon:GetAmmoClip()
            if clip > PLAYERS_DATA[ply].ammos[ammo_type] then
                weapon:SetAmmoClip(PLAYERS_DATA[ply].ammos[ammo_type])
            end
        end
        PlayersCharactersWeapons[charInvID].weapons[i].ammo_clip = weapon:GetAmmoClip()
        weapon:SetAmmoBag(PLAYERS_DATA[ply].ammos[ammo_type] - weapon:GetAmmoClip())
        --print("b", PlayersCharactersWeapons[charInvID].weapons[i])
        --print("holding", char:GetPicked())

        char:PickUp(weapon)

        --print("a", PlayersCharactersWeapons[charInvID].weapons[i])
        PlayersCharactersWeapons[charInvID].weapons[i].weapon = weapon

    else
        -- Doesn't when player spawns but that was expected
        --error("Cannot find ply in GiveInventoryPlayerWeapon")
    end
end

function EquipSlot(char, slot)
    --print("EquipSlot", char:GetID(), slot)
    local charInvID = GetCharacterInventory(char)
    if charInvID then
        local Inv = PlayersCharactersWeapons[charInvID]
        --print(NanosUtils.Dump(Inv.weapons))
        local picked_thing = char:GetPicked()
        if (not picked_thing or (not picked_thing:IsA(Grenade) and not picked_thing:IsA(Melee))) then
            if slot ~= Inv.selected_slot then
                local found_weapon_slot = false

                for i, v in ipairs(Inv.weapons) do
                    if (v.slot == Inv.selected_slot and v.weapon) then
                        if v.weapon:IsValid() then
                            v.ammo_bag = v.weapon:GetAmmoBag()
                            v.ammo_clip = v.weapon:GetAmmoClip()

                            --print("Before:", v, PlayersCharactersWeapons[charInvID].weapons[i])
                            v.destroying = true
                            v.weapon:Destroy()
                            --print("holding WEAPON DESTROYED", char:GetPicked())
                            --print("After:", v, PlayersCharactersWeapons[charInvID].weapons[i])
                        end
                        v.weapon = nil
                        v.destroying = nil
                        found_weapon_slot = true
                        break
                    end
                end
                if not found_weapon_slot then
                    if (picked_thing and picked_thing:IsValid()) then
                        picked_thing:Destroy()
                    end
                end
                for i, v in ipairs(Inv.weapons) do
                    if v.slot == slot then
                        GiveInventoryPlayerWeapon(char, charInvID, i, v)
                        break
                    end
                end
                Inv.selected_slot = slot
            else
                local weapon_given = false

                for i, v in ipairs(Inv.weapons) do
                    if (v.slot == Inv.selected_slot) then
                        if not v.weapon then
                            GiveInventoryPlayerWeapon(char, charInvID, i, v)
                            weapon_given = true
                            break
                        elseif v.weapon:IsValid() then
                            v.ammo_bag = v.weapon:GetAmmoBag()
                            v.ammo_clip = v.weapon:GetAmmoClip()
                            v.destroying = true
                            v.weapon:Destroy()
                            v.destroying = nil

                            GiveInventoryPlayerWeapon(char, charInvID, i, v)
                            weapon_given = true
                            break
                        end
                    end
                end
                if not weapon_given then
                    if (picked_thing and picked_thing:IsValid()) then
                        picked_thing:Destroy()
                    end
                end
            end
            Events.Call("VZ_EquippedInventorySlot", char, slot)
        else
            --print("EquipSlot Locked Because He has Grenade")
        end
    end
end

function RemoveCharacterWeapon(char, slot)
    local charInvID = GetCharacterInventory(char)
    if charInvID then
        for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
            if v.slot == slot then
                if v.weapon then
                    if v.weapon:IsValid() then
                        v.destroying = true
                        v.weapon:Destroy()
                    end
                end
                table.remove(PlayersCharactersWeapons[charInvID].weapons, i)
                break
            end
        end
    end
end

function AddCharacterWeapon(char, weapon_name, equip, insert_sl)
    local charInvID = GetCharacterInventory(char)
    if charInvID then
        --print(NanosUtils.Dump(PlayersCharactersWeapons[charInvID].weapons))

        -- If the player already have this weapon, don't give a new one
        local already_have = false
        for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
            if v.weapon_name == weapon_name then
                already_have = true
            end
        end
        if already_have then
            EquipSlot(char, PlayersCharactersWeapons[charInvID].selected_slot)
            return false
        end


        local inv_w_count = table_count(PlayersCharactersWeapons[charInvID].weapons)
        --print("inv_w_count", inv_w_count)

        -- If the player slots are full, UNEQUIP the weapon in selected_slot
        if (inv_w_count >= 3) then
            for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
                if v.slot == PlayersCharactersWeapons[charInvID].selected_slot then
                    if v.weapon then
                        --print("bef char:Drop()")
                        --print("Dropping Weapon Because Slots Full", char:GetPicked())
                        if v.weapon:IsValid() then
                            v.destroying = true
                            v.weapon:Destroy()
                        end
                        --print("Dropped ? ", char:GetPicked())
                        --print("after char:Drop()")
                    end
                    table.remove(PlayersCharactersWeapons[charInvID].weapons, i)
                    break
                end
            end
        else
            for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
                if v.slot == PlayersCharactersWeapons[charInvID].selected_slot then
                    if v.weapon then
                        v.just_dropped = nil
                    end
                    break
                end
            end
        end

        table.insert(PlayersCharactersWeapons[charInvID].weapons, GenerateWeaponToInsert(weapon_name, ammo_bag, insert_sl, ammo_clip))
        if equip then
            EquipSlot(char, insert_sl)
        else
            EquipSlot(char, PlayersCharactersWeapons[charInvID].selected_slot)
        end
    else
        table.insert(PlayersCharactersWeapons, {
            char = char,
            selected_slot = insert_sl,
            weapons = {
                GenerateWeaponToInsert(weapon_name, ammo_bag, insert_sl, ammo_clip),
            },
        })
        EquipSlot(char, insert_sl)
    end
end

Character.Subscribe("Destroy", function(char)
    local charInvID = GetCharacterInventory(char)
    if charInvID then
        for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
            if (v.weapon and v.weapon:IsValid()) then
                v.destroying = true
                v.weapon:Destroy()
            end
        end
        table.remove(PlayersCharactersWeapons, charInvID)
    end
end)

Weapon.Subscribe("Drop", function(weapon, char, was_triggered_by_player)
    --print("Drop", weapon, char, was_triggered_by_player, weapon:GetMesh())
    local charInvID = GetCharacterInventory(char)
    if charInvID then
        --print(NanosUtils.Dump(PlayersCharactersWeapons[charInvID]))
        for i, v in ipairs(PlayersCharactersWeapons[charInvID].weapons) do
            if (v.weapon and v.weapon == weapon) then
                if not v.destroying then
                    --print("Drop Weapon")
                    if (was_triggered_by_player or v.Dropping) then
                        table.remove(PlayersCharactersWeapons[charInvID].weapons, i)
                    end
                    v.just_dropped = true
                    --print("After Drop Weapon, weapon[1]", PlayersCharactersWeapons[charInvID].weapons[1])
                else
                    v.destroying = nil
                end
                break
            end
        end
    end
end)

Events.SubscribeRemote("Online_Switch_Weapon", function(ply)
    local char = ply:GetControlledCharacter()
    if char then
        if char:GetHealth() > 0 then
            if (not char:GetVehicle()) then
                if PLAYERS_DATA[ply] then
                    if not PLAYERS_DATA[ply].passive then
                        local charInvID = GetCharacterInventory(char)
                        if charInvID then
                            local s_slot = PlayersCharactersWeapons[charInvID].selected_slot + 1
                            if s_slot > 4 then
                                s_slot = 1
                            end
                            EquipSlot(char, s_slot)
                        end
                    end
                end
            end
        end
    end
end)

Weapon.Subscribe("Fire", function(weap, char)
	local ply = char:GetPlayer()
    if ply then
        if PLAYERS_DATA[ply] then
            local name = weap:GetValue("WeaponName")
            if name then
                if PLAYERS_DATA[ply].weapons[name] then
                    if Online_Weapons[name] then
                        if PLAYERS_DATA[ply].ammos[Online_Weapons[name].ammo_type] then
                            PLAYERS_DATA[ply].ammos[Online_Weapons[name].ammo_type] = PLAYERS_DATA[ply].ammos[Online_Weapons[name].ammo_type] - 1
                            if PLAYERS_DATA[ply].ammos[Online_Weapons[name].ammo_type] < 0 then
                                PLAYERS_DATA[ply].ammos[Online_Weapons[name].ammo_type] = 0
                            end
                        end
                    end
                end
            end
        end
    end
end)

function UpdateCurrentWeaponAmmo(char)
    local ply = char:GetPlayer()
    if ply then
        if PLAYERS_DATA[ply] then
            local picked_thing = char:GetPicked()
            if picked_thing then
                local name = picked_thing:GetValue("WeaponName")
                if name then
                    if PLAYERS_DATA[ply].weapons[name] then
                        if Online_Weapons[name] then
                            if PLAYERS_DATA[ply].ammos[Online_Weapons[name].ammo_type] then
                                local bag = PLAYERS_DATA[ply].ammos[Online_Weapons[name].ammo_type] - picked_thing:GetAmmoClip()
                                if bag < 0 then
                                    bag = 0
                                end
                                picked_thing:SetAmmoBag(bag)
                                Events.CallRemote("NeedUpdateCanvasAmmo", ply)
                            end
                        end
                    end
                end
            end
        end
    end
end

function InitPlayerInventoryLink(ply, char)
    if PLAYERS_DATA[ply] then
        if PLAYERS_DATA[ply].weapons_picked then
            for k, v in pairs(PLAYERS_DATA[ply].weapons_picked) do
                AddCharacterWeapon(char, k, false, v.slot)
            end
            EquipSlot(char, 4)
        end
    end
end
Events.Subscribe("OnlineSpawnedPlayerCharacter", function(ply, char)
    InitPlayerInventoryLink(ply, char)
end)

function RemoveAllPickedWeapons(ply)
    if (ply and ply:IsValid()) then
        if PLAYERS_DATA[ply] then
            local char = ply:GetControlledCharacter()
            for k, v in pairs(PLAYERS_DATA[ply].weapons_picked) do
                if char then
                    RemoveCharacterWeapon(char, v.slot)
                end
                PLAYERS_DATA[ply].weapons[k] = nil
            end
            PLAYERS_DATA[ply].weapons_picked = {}
        end
    end
end
Events.SubscribeRemote("RemoveAllPickedWeapons", RemoveAllPickedWeapons)