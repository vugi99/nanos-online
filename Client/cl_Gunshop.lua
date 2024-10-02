

local current_ammos_text

function GenerateCurrentAmmosText(ammos)
    local str = "Current Ammos : <br>"
    for k, v in pairs(Online_Ammo_Types) do
        local value = ammos[k]
        if not value then
            value = 0
        end
        str = str .. " " .. k .. " : " .. tostring(value) .. " <br>"
    end
    return str
end

function GunshopUI(gunshop_id, weapons, weapons_picked, ammos)
    --print("GunshopUI", gunshop_id, NanosTable.Dump(weapons), weapons_picked, ammos)

    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor(50) .. "px"
    dialogPosition.left = math.floor(100) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("Gunshop")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        current_ammos_text = nil
        Events.CallRemote("LeaveGunshop")
        CloseDialog(dialog)
    end)

    local _all_weaps_count = table_count(Online_Weapons)
    local have_weaps_count = table_count(weapons)
    if ((_all_weaps_count - have_weaps_count) > 0) then

        local text = UIText()
        text.setContent("Select a weapon : ")
        text.appendTo(dialog)

        local BuyButton = UIButton()
        local Weapon_Info_text = UIText()

        local WeaponsList = UIOptionList()
        local _index = 1
        local _o_weap_new_list = {}
        for k, v in pairs(Online_Weapons) do
            if not weapons_picked[k] then
                if not weapons[k] then
                    WeaponsList.appendOption(_index-1, "Weapon : " .. tostring(k) .. " " .. tostring(v.price) .. "$" .. ", ammo type : " .. v.ammo_type)
                    table.insert(_o_weap_new_list, {k, false})
                else
                    WeaponsList.appendOption(_index-1, "Weapon : " .. tostring(k) .. ", OWNED " .. ", ammo type : " .. v.ammo_type)
                    table.insert(_o_weap_new_list, {k, true})
                end
                _index = _index + 1
            end
        end
        WeaponsList.appendTo(dialog)

        local selected = nil
        local price = nil
        WeaponsList.onChange(function(obj)
            --print(NanosTable.Dump(_o_weap_new_list))
            selected = _o_weap_new_list[obj.getValue()[1]+1]
            price = Online_Weapons[selected[1]].price
            if selected[2] then
                BuyButton.setTitle("Equip Weapon")
            else
                BuyButton.setTitle("Buy Weapon (" .. tostring(price) .. "$)")
            end
            BuyButton.update()
            Events.CallRemote("ShowcaseWeapon", gunshop_id, selected[1])

            Weapon_Info_text.setContent("Weapon : " .. tostring(selected[1]) .. " <br> Weapon Price : " .. tostring(price) .. " <br> Default Ammo : " .. tostring(Online_Ammo_Types[Online_Weapons[selected[1]].ammo_type].sell_unit))
            Weapon_Info_text.update()
        end)

        local Slottext = UIText()
        Slottext.setContent("Select a slot : ")
        Slottext.appendTo(dialog)

        local ticked_slots = {}
        for k, v in pairs(weapons_picked) do
            if Online_Weapons[k] then
                ticked_slots[tostring(v.slot)] = k
            end
        end

        local SlotList = UIOptionList()
        for i=1, 3 do
            if (not ticked_slots[tostring(i)]) then
                SlotList.appendOption(i-1, tostring(i) .. ", free slot")
            else
                SlotList.appendOption(i-1, tostring(i) .. ", weapon " .. ticked_slots[tostring(i)] .. ", ammo_type " .. Online_Weapons[ticked_slots[tostring(i)]].ammo_type)
            end
        end
        SlotList.appendTo(dialog)
        local selectedslot = nil
        SlotList.onChange(function(obj)
            selectedslot = obj.getValue()[1]+1
        end)

        Weapon_Info_text.setContent("")
        Weapon_Info_text.appendTo(dialog)

        BuyButton.setTitle("Select a weapon")
        BuyButton.onClick(function(obj)
            if selected then
                if selectedslot then
                    if OMoney >= price then
                        current_ammos_text = nil
                        CloseDialog(dialog)
                        Events.CallRemote("GunshopSelectWeapon", selected[1], selectedslot)
                    else
                        AddNotification("Gunshop", "You don't have enough money")
                    end
                else
                    Chat.AddMessage("Please select a slot")
                end
            else
                Chat.AddMessage("Please select a weapon")
            end
        end)
        BuyButton.appendTo(dialog)
    end

    local _et = UIText()
    _et.setContent("")
    _et.appendTo(dialog)

    local ammo_top_text = UIText()
    ammo_top_text.setContent("Ammos")
    ammo_top_text.appendTo(dialog)

    current_ammos_text = UIText()
    current_ammos_text.setContent(GenerateCurrentAmmosText(ammos))
    current_ammos_text.appendTo(dialog)

    local BuyAmmoButton = UIButton()

    local AmmoList = UIOptionList()
    local _index2 = 1
    local _o_ammot_new_list = {}
    for k, v in pairs(Online_Ammo_Types) do
        AmmoList.appendOption(_index2-1, "Ammo Type : " .. tostring(k) .. " " .. tostring(v.price) .. "$" .. ", Unit : " .. tostring(v.sell_unit) .. ", Max : " .. tostring(v.max_ammo))
        table.insert(_o_ammot_new_list, k)
        _index2 = _index2 + 1
    end
    AmmoList.appendTo(dialog)

    local selected_ammo = nil
    local ammo_price = nil
    AmmoList.onChange(function(obj)
        selected_ammo = _o_ammot_new_list[obj.getValue()[1]+1]
        ammo_price = Online_Ammo_Types[selected_ammo].price
        BuyAmmoButton.setTitle("Buy Ammo (" .. tostring(ammo_price) .. "$)")
        BuyAmmoButton.update()
    end)

    BuyAmmoButton.setTitle("Select ammo type")
    BuyAmmoButton.onClick(function(obj)
        if selected_ammo then
            if OMoney >= ammo_price then
                Events.CallRemote("GunshopBuyAmmo", selected_ammo)
            else
                AddNotification("Gunshop", "You don't have enough money")
            end
        else
            Chat.AddMessage("Please select the ammo")
        end
    end)
    BuyAmmoButton.appendTo(dialog)

    OpenDialog(dialog, true)
end
Events.SubscribeRemote("OpenGunshopUI", GunshopUI)

RegisterInteract("OnGunShopInteract", "GunshopVendor", function(ent) return "Interact with Gunshop Vendor" end, function(ent) return ent:GetHealth() > 0 end)

Events.Subscribe("OnGunShopInteract", function(char)
    Events.CallRemote("AskGunshopServer", char:GetValue("GunshopVendor"))
end)

Events.SubscribeRemote("UpdateGunshopAmmos", function(ammos)
    if current_ammos_text then
        current_ammos_text.setContent(GenerateCurrentAmmosText(ammos))
        current_ammos_text.update()
    end
end)