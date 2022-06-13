---@author West#9009
---@description Functions for retrieving zones.
---@created 22MAY22

ZONE = {
    ClassName = 'ZONE',
}

function ZONE:New(zone)
    local self = BASE:Inherit(self, BASE:New())

    self.Radius = zone.radius
    self.ZoneID = zone.zoneId
    self.Color = zone.color
    self.properties = zone.properties
    self.x = zone.x
    self.z = zone.y
    self.Name = zone.name
    self.Type = zone.type

    return self
end

function ZONE:FindByName(Name)
    local Zone = __DATABASE._Zones[Name]

    if Zone then
        return Zone
    end

    return nil
end

function ZONE:GetVec2()
    return {x = self.x, z = self.z}
end

function ZONE:GetRandomVec2(SurfaceType)
    local iterations = 0

    local test = function()
        local NotValid = false
        local radius = self.Radius * math.sqrt(math.random())
        local theta = math.random() * 2 * math.pi
        local x = self.x + radius * math.cos(theta)
        local z = self.z + radius * math.sin(theta)

        if land.getSurfaceType({x = x, y = z}) == SurfaceType then

            local Sphere =  {
                id = world.VolumeType.SPHERE,
                params = {
                    point = {x = x, y = land.getHeight({x = x, y = z}), z = z},
                    radius = 50
                }
            }

            local search = function(object)
                if object:isExist() then

                    NotValid = true

                    return false
                end
            end

            world.searchObjects(Object.Category.SCENERY, Sphere, search)
            world.searchObjects(Object.Category.UNIT, Sphere, search)

            if NotValid then
                return nil
            end

            return {x = x, z = z}
        else
            return nil
        end
    end

    while(iterations < 100) do
        local result = test()

        if result then
            return result
        end

        iterations = iterations + 1
    end
end

function ZONE:GetVec3()
    local Vec3 = self:GetVec2()
    Vec3.y = land.getHeight({x = Vec3.x, y = Vec3.z})

    return Vec3
end

function ZONE:Illuminate()
    local Vec3 = self:GetVec3()

    Vec3.y = Vec3.y + 300

    trigger.action.illuminationBomb(Vec3)

    return self
end

function ZONE:GetName()
    return self.Name
end
