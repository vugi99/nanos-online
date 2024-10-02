
local ATM_Text
local WaitingForConfirmation

local function ATMGetDynamicText()
    return "Bank Money : " .. tostring(OBankMoney) .. " <br> Money : " .. tostring(OMoney)
end

function ATMUI()
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor((ScreenY - 250) / 2) .. "px"
    dialogPosition.left = math.floor((ScreenX - 600) / 2) .. "px !important"
    dialogPosition.width = "600px"

    local dialog = UIDialog()
    dialog.setTitle("ATM")
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.onClickClose(function(obj)
        ATM_Text = nil
        CloseDialog(dialog)
    end)

    local text = UIText()
    ATM_Text = text
    text.setContent(ATMGetDynamicText())
    text.appendTo(dialog)

    local AmountInput = UITextField()
    AmountInput.setPlaceholder("Amount")
    AmountInput.appendTo(dialog)

    local WithdrawButton = UIButton()
    WithdrawButton.setTitle("Withdraw")
    WithdrawButton.onClick(function(obj)
        local amount = tonumber(AmountInput.getValue())
        if amount then
            if amount > 0 then
                if math.floor(amount) == amount then
                    if (OBankMoney - amount) >= 0 then
                        if not WaitingForConfirmation then
                            Events.CallRemote("ATMWithdraw", amount)
                            WaitingForConfirmation = true
                        end
                    end
                end
            end
        end
    end)
    WithdrawButton.appendTo(dialog)

    local DepositButton = UIButton()
    DepositButton.setTitle("Deposit")
    DepositButton.onClick(function(obj)
        local amount = tonumber(AmountInput.getValue())
        if amount then
            if amount > 0 then
                if math.floor(amount) == amount then
                    if (OMoney - amount) >= 0 then
                        if not WaitingForConfirmation then
                            Events.CallRemote("ATMDeposit", amount)
                            WaitingForConfirmation = true
                        end
                    end
                end
            end
        end
    end)
    DepositButton.appendTo(dialog)

    OpenDialog(dialog, true)
end


RegisterInteract("OnAtmInteract", "ATM", function(ent) return "Interact with ATM" end)

Events.Subscribe("OnAtmInteract", function(atm)
    ResetCanInteractWith()
    ATMUI()
end)

Events.SubscribeRemote("ATMConfirmation", function()
    if ATM_Text then
        ATM_Text.setContent(ATMGetDynamicText())
        ATM_Text.update()
    end
    WaitingForConfirmation = nil
end)