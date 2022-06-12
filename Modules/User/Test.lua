---@author West#9009
---@description Test Module.
---@created 20MAY22

---@type BASE
TEST = {
    ClassName = 'TEST',
    iterations = 0
}

function TEST:New()
    local self = BASE:Inherit(self, BASE:New())
    self:HandleEvent(ENUMS.EVENTS.Birth, self.OnEventBirth)
    return self
end

function TEST:Test1()
    local zone1 = ZONE:FindByName('Test1')

    local static = SPAWN:NewStaticFromType('Invisible Farp', 'Heliports', 80, nil, nil, 'invisiblefarp', true):SpawnFromZone(zone1)

    self:Schedule(10, function() self:L(static:GetVec3())  end)

    zone1:Illuminate()

    return self
end

function TEST:Test2()
    local group = GROUP:FindByName('GroupTest')
    local units = group:GetUnits()

    for _, unit in ipairs(units) do
        self:L(unit:GetVec3())
    end

    self:Schedule(10, function() group:Destroy() end)
    return self
end

function TEST:Test3()
    SET:New('Zones'):FilterCategory(Group.Category.SHIP):ForEach(function(group)
        self:Info(group:GetName())
    end, self)
end

function TEST:OnEventBirth(EventData)
    self:Info('Name: %s', EventData.IniDCSUnitName)
end

TEST:New():Test3()
