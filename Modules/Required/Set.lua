---@author West#9009
---@description Static Set module. The set only returns collections that existed at the time of installation.
---@created 20MAY22

---@type BASE
SET = {
    ClassName = 'SET'
}

function SET:CreateFrom(Type)
    local self = BASE:Inherit(self, BASE:New())

    local Classes = {
        ['Groups'] = __DATABASE:GetGroups(),
        ['Units'] = __DATABASE:GetUnits(),
        ['Statics'] = __DATABASE:GetStatics(),
        ['Airbases'] = __DATABASE:GetAirbases(),
        ['Zones'] = __DATABASE:GetZones()
    }

    if not Classes[Type] then return nil end

    self.Class = ROUTINES.util.deepCopy(Classes[Type])
    self.Type = Type

    return self
end

function SET:RemoveByName(Name)
    if self.Class[Name] then
        self.Class[Name] = nil
    end

    return self
end

function SET:FilterName(RegEx)
    for Name, _ in pairs(self.Class) do
        if not string.match(Name, RegEx) then
            self:RemoveByName(Name)
        end
    end

    return self
end

function SET:FilterCategory(Category)
    for Name, Object in pairs(self.Class) do
        if not Object.GetCategory then break end

        local ObjectCategory = Object:GetCategory()

        if Category ~= ObjectCategory then
            self:RemoveByName(Name)
        end
    end

    return self
end

function SET:ForEach(Callback, ...)
    for _, object in pairs(self.Class) do
        Callback(object, ...)
    end

    return self
end
