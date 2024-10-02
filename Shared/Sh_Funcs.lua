


function table_count(ta)
    local count = 0
    for k, v in pairs(ta) do count = count + 1 end
    return count
end

function table_last_count(ta)
    local count = 0
    for i, v in ipairs(ta) do
        if v then
            count = count + 1
        end
    end
    return count
end

function SearchMapData(tbl, key, value)
    local ret = {}
    if tbl then
        for k, v in pairs(tbl) do
            if (v[key] and v[key] == value) then
                table.insert(ret, v)
            end
        end
    end
    return ret
end

function SearchMapDataFirst(tbl, key, value)
    if tbl then
        for k, v in pairs(tbl) do
            if (v[key] and v[key] == value) then
                return v
            end
        end
    end
end

function GetFirstKey(tbl)
    for k, v in pairs(tbl) do
        return k
    end
end

function ONLINE_DEV_IsModeEnabled(mode)
    if ONLINE_DEV_CONFIG.ENABLED then
        return ONLINE_DEV_CONFIG.DEV_MODES[mode]
    else
        return false
    end
end
Package.Export("ONLINE_DEV_IsModeEnabled", ONLINE_DEV_IsModeEnabled)

function GetRandomPlayerInDimension(dim_id)
    local dim = VDimension.GetObjectFromDimension(dim_id)
    if dim then
        local plys = dim:GetEntitiesOfClass("Player")
        if plys then
            local list = {}
            local c = 0
            for k, v in pairs(plys) do
                table.insert(list, k)
                c = c + 1
            end
            if c > 0 then
                return list[math.random(c)]
            end
        end
    end
    return false
end

function clamp(val, minval, maxval, valadded)
    if val + valadded <= maxval then
        if val + valadded >= minval then
            val = val + valadded
        else
            val = minval
        end
    else
        val = maxval
    end
    return val
end

function split_str(str,sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

function CopyVector(vec)
    return Vector(vec.X, vec.Y, vec.Z)
end

function CopyRotation(rot)
    return Rotation(rot.Pitch, rot.Yaw, rot.Roll)
end

function Online_Text3D(attach_host, attach_rule, text, scale, color, location, relative_location)
    location = location or Vector()
    local text_3d = TextRender(
        location,
        Rotator(),
        text,
        scale,
        color,
        FontType.OpenSans,
        TextRenderAlignCamera.AlignCameraRotation
    )
    if attach_host then
        text_3d:SetDimension(attach_host:GetDimension())
    end
    text_3d:SetTextSettings(0, 0, 0, TextRenderHorizontalAlignment.Center, TextRenderVerticalAlignment.Center)
    if attach_host then
        text_3d:AttachTo(attach_host, attach_rule, "", 0, false)
        if relative_location then
            text_3d:SetRelativeLocation(relative_location)
        end
    end
    text_3d:SetMaterialColorParameter("Emissive", color * 2)

    return text_3d
end

function DeepCopyTable(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[DeepCopyTable(orig_key, copies)] = DeepCopyTable(orig_value, copies)
            end
            setmetatable(copy, DeepCopyTable(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end