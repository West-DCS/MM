---@author West#9009
---@description Airbase object wrapper.
---@created 25MAY22

---@type OBJECT
---@class AIRBASE
AIRBASE = {
    ClassName = 'AIRBASE',
}

function AIRBASE:New(Name)
    local self = BASE:Inherit(self, OBJECT:New(Name))

    return self
end

function AIRBASE:FindByName(Name)
    local Airbase = __DATABASE._Airbases[Name]

    if Airbase then
        return Airbase
    end

    return nil
end

function AIRBASE:GetDCSObject()
    local DCSObject = Airbase.getByName(self.Name)

    if DCSObject then
        return DCSObject
    end

    return nil
end
