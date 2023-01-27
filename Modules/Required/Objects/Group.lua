---@author West#9009
---@description Group object wrapper.
---@created 22MAY22

---@type OBJECT
---@class GROUP
GROUP = {
    ClassName = 'GROUP',
}

function GROUP:New(Name)
    local self = BASE:Inherit(self, OBJECT:New(Name))

    return self
end

function GROUP:FindByName(Name)
    local Group = __DATABASE._Groups[Name]

    if Group then
        return Group
    end

    return nil
end

function GROUP:GetDCSObject()
    local DCSObject = Group.getByName(self.Name)

    if DCSObject then
        return DCSObject
    end

    return nil
end

function GROUP:Activate()
    local DCSGroup = self:GetDCSObject()

    if not DCSGroup then return nil end

    DCSGroup:activate()
end

function GROUP:Destroy()
    local DCSGroup = self:GetDCSObject()

    if DCSGroup then
        local Units = self:GetUnits()

        if Units then
            for _, unit in ipairs(Units) do
                unit:Destroy()
            end
        end

        DCSGroup:destroy()
    end
end

function GROUP:GetUnits()
    local DCSGroup = self:GetDCSObject()

    if DCSGroup then
        local DCSUnits = DCSGroup:getUnits()

        if DCSUnits then
            local Units = {}

            for _, unit in ipairs(DCSUnits) do
                table.insert(Units, UNIT:FindByName(unit:getName()))
            end

            return Units
        end
    end

    return nil
end

function GROUP:GetDCSUnits()
    local DCSGroup = self:GetDCSObject()

    if not DCSGroup then return nil end

    local DCSUnits = DCSGroup:getUnits()

    if not DCSUnits then return nil end

    return DCSUnits
end

function GROUP:GetCountry()
    local Units = self:GetUnits()

    if not Units then return nil end

    return Units[1]:GetCountry()
end

function GROUP:GetID()
    local DCSGroup = self:GetDCSObject()

    if not DCSGroup then return end

    return DCSGroup:getID()
end
