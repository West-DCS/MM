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

function ZONE:GetName()
    return self.Name
end
