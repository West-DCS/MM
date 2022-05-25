---@author West#9009
---@description DCS object helper functions.
---@created 21MAY22

---@type BASE
---@class OBJECT
OBJECT = {
    ClassName = 'OBJECT',
    Name = '',
}

function OBJECT:New(Name)
    local self = BASE:Inherit(self, BASE:New())

    self.Name = Name

    return self
end

function OBJECT:GetDCSObject()
    return nil
end

function OBJECT:Destroy()
    local DCSObject = self:GetDCSObject()

    if DCSObject then
        DCSObject:destroy()
    end
end

function OBJECT:GetName()
    return self.Name
end

function OBJECT:GetDesc()
    local DCSObject = self:GetDCSObject()

    if DCSObject then
        return DCSObject:getDesc()
    end

    return nil
end

function OBJECT:GetLife()
    local desc = self:GetDesc()

    if desc then
        if desc.life then
            return desc.life
        end
    end

    return nil
end

function OBJECT:IsExist()
    local DCSObject = self:GetDCSObject()

    if DCSObject then
        return DCSObject:isExist()
    end

    return nil
end

function OBJECT:GetType()
    local DCSObject = self:GetDCSObject()

    if DCSObject then
        return DCSObject:getTypeName()
    end

    return nil
end

function OBJECT:GetCategory()
    local DCSObject = self:GetDCSObject()

    if DCSObject then
        return DCSObject:getCategory()
    end

    return nil
end

function OBJECT:GetVec3()
    local DCSObject = self:GetDCSObject()

    if DCSObject then
        return DCSObject:getPoint()
    end

    return nil
end

function OBJECT:InAir()
    local DCSObject = self:GetDCSObject()

    if DCSObject then
        return DCSObject:inAir()
    end

    return nil
end

function OBJECT:GetCoalition()
    local DCSObject = self:GetDCSObject()

    if DCSObject then
        return DCSObject:getCoalition()
    end

    return nil
end
