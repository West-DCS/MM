---@author West#9009
---@description Unit object wrapper.
---@created 22MAY22

UNIT = {
    ClassName = 'UNIT',
}

function UNIT:New(Name, ucid)
    local self = BASE:Inherit(self, OBJECT:New(Name))

    self.ucid = ucid or nil

    return self
end

function UNIT:FindByName(Name)
    local Unit = __DATABASE._Units[Name]

    if Unit then
        return Unit
    end

    return nil
end

function UNIT:GetDCSObject()
    local DCSObject = Unit.getByName(self.Name)

    if DCSObject then
        return DCSObject
    end

    return nil
end

function UNIT:GetPlayerName()
    local DCSObject = self:GetDCSObject()

    if DCSObject then
        return DCSObject:getPlayerName()
    end

    return nil
end

function UNIT:GetCountry()
    local DCSObject = self:GetDCSObject()

    if DCSObject then
        return DCSObject:getCountry()
    end

    return nil
end

function UNIT:GetID()
    local DCSUnit = self:GetDCSObject()

    if not DCSUnit then return end

    return DCSUnit:getID()
end

function UNIT:GetUCID()
    return self.ucid
end

function UNIT:Kick(Message)
    if not self.ucid then return end

    NET:KickByUCID(self.ucid, Message or nil)

    return self
end

function UNIT:KickToSpectators(Message)
    if not self.ucid then return end

    NET:KickToSpectatorsByUCID(self.ucid, Message)

    return self
end