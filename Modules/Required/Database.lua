---@author West#9009
---@description Databasing of DCS objects.
---@created 21MAY22

---@type BASE
---@class DATABASE
DATABASE = {
    ClassName = 'DATABASE',
    _Groups = {},
    _Units = {},
    _Statics = {},
    _Zones = {},
    _Airbases = {},
    _GroupIterator = 1
}

function DATABASE:New()
    local self = BASE:Inherit(self, BASE:New())

    self:HandleEvent(ENUMS.EVENTS.Birth, self._OnBirth)
    self:HandleEvent(ENUMS.EVENTS.Dead, self._OnGone)
    self:HandleEvent(ENUMS.EVENTS.Crash, self._OnGone)
    self:HandleEvent(ENUMS.EVENTS.RemoveUnit, self._OnGone)
    self:HandleEvent(ENUMS.EVENTS.PlayerLeaveUnit, self._OnGone)
    self:_SearchGroups('Groups')
    self:_SearchGroups('Statics')
    self:_SearchGroups('Airbases')
    self:_SearchZones()

    return self
end

function DATABASE:Add(Table, Name, class, ...)
    if not Table[Name] then
        Table[Name] = class:New(...)

        return Table[Name]
    end

    return nil
end

function DATABASE:Remove(Table, Name)
    if Table[Name] then
        Table[Name] = nil

        return true
    end

    return false
end

function DATABASE:_SearchGroups(search)
    local Coalitions = {}

    if search == 'Groups' then
        Coalitions.Red = coalition.getGroups(coalition.side.RED)
        Coalitions.Blue = coalition.getGroups(coalition.side.BLUE)
        Coalitions.Neutral = coalition.getGroups(coalition.side.NEUTRAL)
    elseif search == 'Statics' then
        Coalitions.Red = coalition.getStaticObjects(coalition.side.RED)
        Coalitions.Blue = coalition.getStaticObjects(coalition.side.BLUE)
        Coalitions.Neutral = coalition.getStaticObjects(coalition.side.NEUTRAL)
    elseif search == 'Airbases' then
        Coalitions.Red = coalition.getAirbases(coalition.side.RED)
        Coalitions.Blue = coalition.getAirbases(coalition.side.BLUE)
        Coalitions.Neutral = coalition.getAirbases(coalition.side.NEUTRAL)
    end

    for _, data in pairs(Coalitions) do
        for _, group in pairs(data) do
            if group:isExist() then
                local GroupName = group:getName()

                if search == 'Statics' then
                    self:Add(self._Statics, GroupName, STATIC, GroupName)
                elseif search == 'Airbases' then
                    self:Add(self._Airbases, GroupName, AIRBASE, GroupName)
                elseif search == 'Groups' then
                    self:Add(self._Groups, GroupName, GROUP, GroupName)

                    local Units = group:getUnits()

                    for _, unit in pairs(Units) do
                        local UnitName = unit:getName()

                        self:Add(self._Units, UnitName, UNIT, UnitName)
                    end
                end
            end
        end
    end
end

function DATABASE:_SearchZones()
    local Zones = env.mission.triggers.zones

    for _, zone in pairs(Zones) do
        local ZoneName = zone.name

        self:Add(self._Zones, ZoneName, ZONE, zone)
    end
end

function DATABASE:_OnBirth(Event)
    if Event.IniDCSUnit then
        if Event.IniObjectCategory == 3 then
            self:Add(self._Statics, Event.IniDCSUnitName, STATIC, Event.IniDCSUnitName)
        elseif Event.IniObjectCategory == 1 then
            self:Add(self._Groups, Event.IniDCSGroupName, GROUP, Event.IniDCSGroupName)
            self:Add(self._Units, Event.IniDCSUnitName, UNIT, Event.IniDCSUnitName)

            if Airbase.getByName(Event.IniDCSUnitName) then
                self:Add(self._Airbases, Event.IniDCSUnitName, AIRBASE, Event.IniDCSUnitName)
            end
        end
    end
end

function DATABASE:_OnGone(Event)
    if Event.IniDCSUnit then
        if Event.IniObjectCategory == 3 then
            self:Remove(self._Statics, Event.IniDCSUnitName)
        elseif Event.IniObjectCategory == 1 then
            self:Remove(self._Units, Event.IniDCSUnitName)
            if Airbase.getByName(Event.IniDCSUnitName) then
                self:Remove(self._Airbases, Event.IniDCSUnitName)
            end
        end
    end
end

function DATABASE:_Iterate()
    self._GroupIterator = self._GroupIterator + 1

    return self._GroupIterator - 1
end

function DATABASE:GetGroups()
    return self._Groups
end

function DATABASE:GetUnits()
    return self._Units
end

function DATABASE:GetZones()
    return self._Zones
end

function DATABASE:GetAirbases()
    return self._Airbases
end

function DATABASE:GetStatics()
    return self._Statics
end
