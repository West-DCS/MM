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

    self:HandleEvent(ENUMS.EVENTS.Birth, self._OnEventBirth)

    return self
end

function TEST:_OnEventBirth(EventData)

    if self.iterations == 0 then
        self.iterations = self.iterations + 1

        local zone = ZONE:FindByName('Larnaca Logistics Center')
        local farp = SPAWN:NewStaticFromType('Invisible FARP', 'Heliports', 80, nil,
                nil, 'invisiblefarp', true)

        farp:SpawnFromZone(zone)

        self:Schedule(10, function() farp:Destroy() end)
        self.iterations = self.iterations + 1
    end

end

TEST:New()
