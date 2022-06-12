---@author West#9009
---@description Test Module.
---@created 20MAY22

---@type BASE
SET = {
    ClassName = 'SET'
}

function SET:New(Type)
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

function SET:FilterName(RegEx)
    for key, object in pairs(self.Class) do
        local name = object:GetName()

        if not string.match(name, RegEx) then
            self.Class[key] = nil
        end
    end

    return self
end

function SET:FilterCategory(Category)
    for key, object in pairs(self.Class) do
        if not object.GetCategory then break end

        local ObjectCategory = object:GetCategory()

        if Category ~= ObjectCategory then
            self.Class[key] = nil
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
