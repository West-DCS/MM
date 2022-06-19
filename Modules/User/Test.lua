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

-- SPAWN IN ZONE TEST
function TEST:Test1()
    local zone1 = ZONE:FindByName('Test1')

    local static = SPAWN:NewStaticFromType('Invisible Farp', 'Heliports', 80, nil, nil, 'invisiblefarp', true):SpawnFromZone(zone1)

    self:Schedule(10, function() self:L(static:GetVec3())  end)

    zone1:Illuminate()

    return self
end

-- GET UNIT AND GROUP DESTROY TEST
function TEST:Test2()
    local group = GROUP:FindByName('GroupTest')
    local units = group:GetUnits()

    for _, unit in ipairs(units) do
        self:L(unit:GetVec3())
    end

    self:Schedule(10, function() group:Destroy() end)
    return self
end

-- SET TEST
function TEST:Test3()
    SET:CreateFrom('Zones'):FilterCategory(Group.Category.SHIP):ForEach(function(group)
        self:Info(group:GetName())
    end, self)
end

-- SCHEDULE REPEAT TEST
function TEST:Test4()
    local schedule = self:ScheduleRepeat(1, function(arg, arg2) self:L({arg, arg2}) end, 'three', 'two')
    self:Schedule(10, function() self:ScheduleStop(schedule) end)
end

-- PERSISTENCE TEST
function TEST:Test5()
    if PERSIST then
        PERSIST:IgnoreGroup(GROUP:FindByName('GroupTest2'))
        PERSIST:SetSchedule(1)

        PERSIST:Start()
    end
end

function TEST:Test6()
    local menu1 = MENU:New('Logistics')
    local menu2 = MENU:New('1')
    local menu3 = MENU:New('2')
    menu1:AddSubMenu(menu2)
    local test = function()  BASE:L{'Test'} end
    menu2:AddCommand('Test', test)

    --local group = GROUP:FindByName('AAAA')
    menu1:AddToCoalition(coalition.side.RED)

    self:Schedule(10, function() menu2:RemoveFromCoalition(test, coalition.side.RED) end)
end

function TEST:OnEventBirth(EventData)
    if not EventData.IniGroupName == 'AAAA' then return end

    self:Info('I was born %s', EventData.IniGroupName)
    self:Test6()

end

TEST:New()
