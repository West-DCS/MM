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
    _GroupIterator = 1
}

function DATABASE:New()
    local self = BASE:Inherit(self, BASE:New())

    self:HandleEvent(ENUMS.EVENTS.Birth, self._OnBirth)
    self:HandleEvent(ENUMS.EVENTS.Dead, self._OnGone)
    self:HandleEvent(ENUMS.EVENTS.Crash, self._OnGone)
    self:_SearchGroups()
    self:_SearchGroups(true)
    self:_SearchZones()

    return self
end

function DATABASE:Add(Table, Name, class, ...)
    if not Table[Name] then
        Table[Name] = class:New(...)

        return true
    end

    return false
end

function DATABASE:Remove(Table, Name)
    if Table[Name] then
        Table[Name] = nil

        return true
    end

    return false
end

function DATABASE:_SearchGroups(static)
    local Coalitions = {}

    if not static then
        Coalitions.Red = coalition.getGroups(coalition.side.RED)
        Coalitions.Blue = coalition.getGroups(coalition.side.BLUE)
        Coalitions.Neutral = coalition.getGroups(coalition.side.NEUTRAL)
    else
        Coalitions.Red = coalition.getStaticObjects(coalition.side.RED)
        Coalitions.Blue = coalition.getStaticObjects(coalition.side.BLUE)
        Coalitions.Neutral = coalition.getStaticObjects(coalition.side.NEUTRAL)
    end

    for _, data in pairs(Coalitions) do
        for _, group in pairs(data) do
            if group:isExist() then
                local GroupName = group:getName()

                if static then
                    self:Add(self._Statics, GroupName, STATIC, GroupName)
                else
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
            self:Add(self._Groups, Event.IniDCSGroupName, STATIC, Event.IniDCSGroupName)
            self:Add(self._Units, Event.IniDCSUnitName, STATIC, Event.IniDCSUnitName)
        end
    end
end

function DATABASE:_OnGone(Event)
    if Event.IniDCSUnit then
        if Event.IniObjectCategory == 3 then
            self:Remove(self._Statics, Event.IniDCSUnitName)
        elseif Event.IniObjectCategory == 1 then
            self:Remove(self._Groups, Event.IniDCSGroupName)
            self:Remove(self._Units, Event.IniDCSUnitName)
        end
    end
end

function DATABASE:_Iterate()
    self._GroupIterator = self._GroupIterator + 1
end
