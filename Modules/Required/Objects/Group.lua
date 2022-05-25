---@author West#9009
---@description Group object wrapper.
---@created 22MAY22

---@type OBJECT
---@class GROUP
GROUP = {
    ClassName = 'Group',
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

function GROUP:GetUnits()

end
