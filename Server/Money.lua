

function OBuy(ply, price)
    if PLAYERS_DATA[ply] then
        local pmoney = PLAYERS_DATA[ply].money
        if (pmoney and pmoney >= price) then
            PLAYERS_DATA[ply].money = pmoney - price
            Events.CallRemote("UpdateClientOMoney", ply, PLAYERS_DATA[ply].money)
            return true
        else
            Events.CallRemote("AddNotification", ply, "", "Not Enough Money")
        end
    end
end
Package.Export("OBuy", OBuy)

function OAddMoney(ply, added)
    if PLAYERS_DATA[ply] then
        local pmoney = PLAYERS_DATA[ply].money
        if pmoney then
            PLAYERS_DATA[ply].money = pmoney + added
            Events.CallRemote("UpdateClientOMoney", ply, PLAYERS_DATA[ply].money)
            return true
        end
    end
end
Package.Export("OAddMoney", OAddMoney)

if O_ATM_C then
    for i, v in ipairs(O_ATM_C) do
        local atm = StaticMesh(v.location, v.rotation, ATM_Mesh)
        atm:SetValue("ATM", true, true)
        atm:SetScale(Vector(1, 1, 0.8))
        Online_Text3D(atm, AttachmentRule.SnapToTarget, "ATM", Vector(0.3, 0.3, 0.3), Color.WHITE, nil, Vector(0, 0, 225))
    end
end

Events.Subscribe("PlayerDataLoaded", function(ply)
    Events.CallRemote("UpdateClientOMoney", ply, PLAYERS_DATA[ply].money)
    Events.CallRemote("UpdateClientOBankMoney", ply, PLAYERS_DATA[ply].bank_money)
end)

Events.SubscribeRemote("ATMWithdraw", function(ply, amount)
    if ply:IsValid() then
        local char = ply:GetControlledCharacter()
        if (char and char:IsValid() and char:GetHealth() > 0) then
            if PLAYERS_DATA[ply] then
                if (amount and type(amount) == "number" and amount > 0) then
                    if (PLAYERS_DATA[ply].bank_money - amount) >= 0 then
                        PLAYERS_DATA[ply].bank_money = PLAYERS_DATA[ply].bank_money - amount
                        PLAYERS_DATA[ply].money = PLAYERS_DATA[ply].money + amount
                        Events.CallRemote("UpdateClientOMoney", ply, PLAYERS_DATA[ply].money)
                        Events.CallRemote("UpdateClientOBankMoney", ply, PLAYERS_DATA[ply].bank_money)

                        Events.CallRemote("AddNotification", ply, "ATM", "Withdraw successful")
                    end
                end
            end
        end
        Events.CallRemote("ATMConfirmation", ply)
    end
end)

Events.SubscribeRemote("ATMDeposit", function(ply, amount)
    if ply:IsValid() then
        local char = ply:GetControlledCharacter()
        if (char and char:IsValid() and char:GetHealth() > 0) then
            if PLAYERS_DATA[ply] then
                if (amount and type(amount) == "number" and amount > 0) then
                    if (PLAYERS_DATA[ply].money - amount) >= 0 then
                        PLAYERS_DATA[ply].money = PLAYERS_DATA[ply].money - amount
                        PLAYERS_DATA[ply].bank_money = PLAYERS_DATA[ply].bank_money + amount
                        Events.CallRemote("UpdateClientOMoney", ply, PLAYERS_DATA[ply].money)
                        Events.CallRemote("UpdateClientOBankMoney", ply, PLAYERS_DATA[ply].bank_money)

                        Events.CallRemote("AddNotification", ply, "ATM", "Deposit successful")
                    end
                end
            end
        end
        Events.CallRemote("ATMConfirmation", ply)
    end
end)