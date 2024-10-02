

DEFAULT_DIMENSION = nil

ALL_VDIMENSIONS = {}

VDimension = {}
VDimension.__index = VDimension
VDimension.prototype = {}
VDimension.prototype.__index = VDimension.prototype
VDimension.prototype.constructor = VDimension

Sub_Callbacks = {}

function VDimension.Subscribe(event_name, callback)
    if not Sub_Callbacks[event_name] then
        Sub_Callbacks[event_name] = {}
    end
    Sub_Callbacks[event_name][callback] = true
    --print(NanosUtils.Dump(Sub_Callbacks))
    return callback
end

function VDimension.Unsubscribe(event_name, callback)
    if callback then
        if Sub_Callbacks[event_name] then
            if Sub_Callbacks[event_name][callback] then
                Sub_Callbacks[event_name][callback] = nil
                return true
            end
        end
    else
        Sub_Callbacks[event_name] = nil
        return true
    end
    return false
end

function VDimension.GetPairs()
    return ALL_VDIMENSIONS
end

function VDimension.GetAll()
    local tbl = {}
    for k, v in pairs(ALL_VDIMENSIONS) do
        if v:IsValid() then
            table.insert(tbl, v)
        end
    end
    return tbl
end

function VDimension.CallEvent(event_name, ...)
    if Sub_Callbacks[event_name] then
        for k, v in pairs(Sub_Callbacks[event_name]) do
            k(...)
        end
    end
end

function VDimension.prototype:IsValid(is_from_self)
    local valid = self.Valid
    if (not valid and is_from_self) then
        Package.Err() -- Throw real error
    end
    return valid
end

function VDimension.prototype:__eq(other)
    if other.ID then
        if other.ID == self.ID then
            return true
        end
    end
    return false
end

function VDimension.prototype:GetID()
    if self:IsValid(true) then
        return self.ID
    end
end

function VDimension.prototype:GetName()
    if self:IsValid(true) then
        return self.Stored.Name
    end
end

function VDimension.prototype:GetEntities()
    if self:IsValid(true) then
        return self.Stored.Entities
    end
end

function VDimension.prototype:GetEntitiesOfClass(classname)
    if self:IsValid(true) then
        return self.Stored.Entities[classname]
    end
end

function VDimension.prototype:GetEntitiesOfClassCopy(classname)
    if self:IsValid(true) then
        local tbl = {}
        if self.Stored.Entities[classname] then
            for k, v in pairs(self.Stored.Entities[classname]) do
                tbl[k] = v
            end
        end
        return tbl
    end
end

function VDimension.prototype:AddActor(classname, actor)
    if self:IsValid(true) then
        if not self.Stored.Entities[classname] then
            self.Stored.Entities[classname] = {}
        end
        if (actor.Subscribe) then
            self.Stored.Entities[classname][actor] = actor:Subscribe("Destroy", function()
                if self:IsValid() then
                    if (self.Stored.Entities[classname] and self.Stored.Entities[classname][actor]) then
                        --actor:Unsubscribe("Destroy", self.Stored.Entities[classname][actor])
                        self.Stored.Entities[classname][actor] = nil

                        if classname == "Player" then
                            if self.Stored.destroy_on_empty then
                                if table_count(self.Stored.Entities["Player"]) <= 0 then
                                    self:Destroy()
                                end
                            end
                        end
                    end
                end
            end)
        else
            self.Stored.Entities[classname][actor] = true
        end
        return true
    end
end

function VDimension.prototype:Destroy()
    if self:IsValid(true) then
        if ONLINE_DEV_IsModeEnabled("DIMENSIONS_DEBUG") then
            print("Dimension " .. self:GetName() .. " (" .. tostring(self:GetID()) .. ") Destroy")
        end

        local ents = self.Stored.Entities
        for k, v in pairs(ents) do
            for k2, v2 in pairs(v) do
                if k2:IsValid() then
                    if k2.Destroy then
                        --print("Destroy", k2)
                        k2:Destroy()
                    end
                end
            end
        end
        self.Stored.Entities = {}
        self.Valid = false
        ALL_VDIMENSIONS[self.ID] = nil
    end
end

function VDimension.GetObjectFromDimension(nb)
    if nb then
        return ALL_VDIMENSIONS[nb]
    end
end

function VDimension.Create(name, destroy_on_empty)
    if (name and type(name) == "string") then
        local dim = setmetatable({}, VDimension.prototype)

        local this_id = table_last_count(ALL_VDIMENSIONS)

        dim.Stored = {}
        dim.Stored.Name = name
        dim.ID = this_id + 1
        dim.Stored.destroy_on_empty = destroy_on_empty

        dim.Stored.Entities = {}

        dim.Valid = true

        ALL_VDIMENSIONS[this_id + 1] = dim

        VDimension.CallEvent("Spawn", dim)

        if ONLINE_DEV_IsModeEnabled("DIMENSIONS_DEBUG") then
            print("Dimension " .. name .. " (" .. tostring(dim:GetID()) .. ") Created")
        end

        return ALL_VDIMENSIONS[this_id + 1]
    end
end

for k, v in pairs(debug.getregistry().classes) do
    local meta = getmetatable(v)
    if (meta and meta.__call) then
        if (v.__function.SetDimension and v.__function.Subscribe) then
            _ENV[v.__name].Subscribe("DimensionChange", function(self, old_dimension, new_dimension)
                --print(v.__name, "", self, old_dimension, new_dimension)
                local odim = VDimension.GetObjectFromDimension(old_dimension)
                if (odim and odim.Stored.Entities[v.__name]) then
                    if type(odim.Stored.Entities[v.__name][self]) == "function" then
                        self:Unsubscribe("Destroy", odim.Stored.Entities[v.__name][self])
                    end
                    odim.Stored.Entities[v.__name][self] = nil
                    if v.__name == "Player" then
                        if odim.Stored.destroy_on_empty then
                            if table_count(odim.Stored.Entities[v.__name]) <= 0 then
                                odim:Destroy()
                            end
                        end
                    end
                end
                local ndim = VDimension.GetObjectFromDimension(new_dimension)
                if ndim then
                    ndim:AddActor(v.__name, self)
                else
                    Console.Warn("Missing dimension object for dimension " .. tostring(new_dimension))
                end
            end)
        end
    end
end

DEFAULT_DIMENSION = VDimension.Create("DEFAULT")

Player.Subscribe("Spawn", function(ply)
    DEFAULT_DIMENSION:AddActor("Player", ply)
end)
for k, v in pairs(Player.GetPairs()) do
    v:SetDimension(DEFAULT_DIMENSION.ID)
    --DEFAULT_DIMENSION:AddActor("Player", v)
end

if ONLINE_DEV_IsModeEnabled("DIMENSIONS_DEBUG") then
    Player.Subscribe("DimensionChange", function(ply, old_dimension, new_dimension)
        print("Player DimensionChange", ply, old_dimension, new_dimension)
    end)
end