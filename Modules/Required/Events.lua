---@author West#9009
---@description Event dispatching.
---@created 20MAY22

EVENTS = {
    ClassName = 'EVENTS'
}

function EVENTS:New()
    local self = BASE:Inherit(self, BASE:New())

    world.addEventHandler(self)

    return self
end

function EVENTS:onEvent(event)
    self:Log('info', 'An Event has occurred.')
end
