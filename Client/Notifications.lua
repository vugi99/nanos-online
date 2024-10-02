

local notifications = {}
activity_notifications = {}

local y_dist = 130
local y_dist_activity = 180

function UpdateNotificationsPos(deleted_notif_posy)
   local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
   for i,v in ipairs(notifications) do
      if v[2] < deleted_notif_posy then
        local dialogPosition = UICSS()
        dialogPosition.top = math.floor(v[2] + y_dist) .. "px"
        dialogPosition.left = math.floor(ScreenX - 280) .. "px !important"
        dialogPosition.width = "250px"
        v[1].setCSS(dialogPosition)
        v[1].update()
        v[2] = v[2] + y_dist
      end
   end
end

function AddNotification(title, content, timeout)
    timeout = timeout or 5000
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor(ScreenY - y_dist*(#notifications+1)) .. "px"
    dialogPosition.left = math.floor(ScreenX - 280) .. "px !important"
    dialogPosition.width = "250px"

    local dialog = UIDialog()
    dialog.setTitle(title)
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.setCanClose(false)

    local text = UIText()
    text.setContent(content)
    text.appendTo(dialog)
    table.insert(notifications, {dialog, ScreenY - y_dist*(#notifications+1)})
    Timer.SetTimeout(function()
        for i,v in ipairs(notifications) do
           if v[1] == dialog then
              table.remove(notifications, i)
              UpdateNotificationsPos(v[2])
              break
           end
        end
        dialog.destroy()
    end, timeout)
end
Events.SubscribeRemote("AddNotification", AddNotification)

function UpdateActivityNotificationsPos(deleted_notif_posy)
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    for i,v in ipairs(activity_notifications) do
       if v[2] < deleted_notif_posy then
         local dialogPosition = UICSS()
         dialogPosition.top = math.floor(v[2] + y_dist_activity) .. "px"
         dialogPosition.left = math.floor(ScreenX - 580) .. "px !important"
         dialogPosition.width = "250px"
         v[1].setCSS(dialogPosition)
         v[1].update()
         v[2] = v[2] + y_dist_activity
       end
    end
 end

function AddActivityNotification(title, content, eventname, lobbyid, timeout)
    timeout = timeout or 15000
    local ScreenX, ScreenY = Viewport.GetViewportSize().X, Viewport.GetViewportSize().Y
    local dialogPosition = UICSS()
    dialogPosition.top = math.floor(ScreenY - y_dist_activity*(#activity_notifications+1)) .. "px"
    dialogPosition.left = math.floor(ScreenX - 580) .. "px !important"
    dialogPosition.width = "250px"

    local dialog = UIDialog()
    dialog.setTitle(title)
    dialog.appendTo(UIFramework)
    dialog.setCSS(dialogPosition)
    dialog.setCanClose(false)

    local text = UIText()
    text.setContent(content)
    text.appendTo(dialog)

    local JoinActivityButton = UIButton()
    JoinActivityButton.setTitle("Join")
    JoinActivityButton.onClick(function(obj)
        if (IsDialogFree()) then
            for i,v in ipairs(activity_notifications) do
                v[1].destroy()
            end
            activity_notifications = {}
            Events.Call(eventname, lobbyid)
        else
            Chat.AddMessage("You can't join this activity")
        end
    end)
    JoinActivityButton.appendTo(dialog)

    table.insert(activity_notifications, {dialog, ScreenY - y_dist_activity*(#activity_notifications+1)})
    Timer.SetTimeout(function()
        for i,v in ipairs(activity_notifications) do
           if v[1] == dialog then
              table.remove(activity_notifications, i)
              UpdateActivityNotificationsPos(v[2])
              dialog.destroy()
              break
           end
        end
    end, timeout)
end
Events.SubscribeRemote("AddActivityNotification", AddActivityNotification)