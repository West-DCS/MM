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

        local zone1 = ZONE:FindByName('Test1')
        local zone2 = ZONE:FindByName('Test2')

        --if land.getSurfaceType(zone:GetVec2()) == land.SurfaceType.ROAD then
        --    self:Log('info', 'TYPE ROAD')
        --end

        --local farp = SPAWN:NewStaticFromType('Invisible FARP', 'Heliports', 80, nil,
        --        nil, 'invisiblefarp', true):SpawnFromZone(zone)
        --
        --self:Schedule(10, function(farp) farp:Destroy() end, farp)

        for i=1, 50 do
            SPAWN:NewGroundFromType('Soldier M4', 80):SpawnFromZoneRandomVec2(zone1, land.SurfaceType.LAND)
            SPAWN:NewGroundFromType('Infantry AK ver2', 81):SpawnFromZoneRandomVec2(zone2, land.SurfaceType.LAND)
        end

        zone1:Illuminate()
        --zone2:Illuminate()


        self.iterations = self.iterations + 1
    end

end

TEST:New()
