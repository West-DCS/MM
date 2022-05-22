---@author West#9009
---@description Databasing of DCS objects.
---@created 21MAY22

DATABASE = {
    ClassName = 'DATABASE',
    _ClientSlots = {},
    _Groups = {},
    _Units = {},
    _Zones = {}
}

function DATABASE:New()
    local self = BASE:Inherit(self, BASE:New())

    --self:HandleEvent(ENUMS.EVENTS.Birth, self._OnEventBirth)
    self:SearchGroups()

    return self
end

function DATABASE:Add(Table, Name, class)
    if not Table[Name] then
        Table[Name] = class:New(Name)

        self:Log('info', 'Adding %s to database.', Name)

        return true
    end

    return false
end

function DATABASE:SearchGroups()
    local Coalitions = {
        Red = coalition.getGroups(coalition.side.RED),
        Blue = coalition.getGroups(coalition.side.BLUE),
        Neutral = coalition.getGroups(coalition.side.NEUTRAL),
    }

    for _, data in pairs(Coalitions) do
        for _, group in pairs(data) do
            if group:isExist() then
                local GroupName = group:getName()

                self:Log('info', 'GroupName: %s', GroupName)

                self:Add(self._Groups, GroupName, GROUP)

                local Units = group:getUnits()

                for _, unit in pairs(Units) do
                    local UnitName = unit:getName()

                    self:Add(self._Units, UnitName, UNIT)
                end
            end
        end
    end
end
