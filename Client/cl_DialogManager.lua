

O_OpenedDialogs = {}

function IsDialogFree()
    return next(O_OpenedDialogs) == nil
end

function OpenDialog(dialog, force_open)
    if (force_open or IsDialogFree()) then
        --UIFramework.webui:BringToFront()
        for k, v in pairs(O_OpenedDialogs) do
            CloseDialog(k)
        end
        Input.SetMouseEnabled(true)
        Input.SetInputEnabled(false)
        O_OpenedDialogs[dialog] = true
        return true
    else
        dialog.destroy()
        return false
    end
end

function CloseDialog(dialog)
    dialog.destroy()
    if O_OpenedDialogs[dialog] then
        O_OpenedDialogs[dialog] = nil
        --print("CloseDialog good")
    end
    if IsDialogFree() then
        Input.SetMouseEnabled(false)
        Input.SetInputEnabled(true)
    end
end

function CloseAllDialogs()
    for k, v in pairs(O_OpenedDialogs) do
        k.destroy()
    end
    Input.SetMouseEnabled(false)
    Input.SetInputEnabled(true)
    O_OpenedDialogs = {}
end