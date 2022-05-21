---@author West#9009
---@description Databasing of DCS objects.
---@created 21MAY22

DATABASE = {
    ClassName = 'DATABASE'
}

function DATABASE:New()
    local self = BASE:Inherit(self, BASE:New())

    --self:HandleEvent(ENUMS.EVENTS.Birth, self._OnEventBirth)

    return self
end

