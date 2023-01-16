---@author West#9009
---@description Net Base object in which child objects are derived. Includes functions for logging.
---@created 16MAY22

---@class BASE
---@field public BASE table Public methods and fields.
---@field public ClassName string The name of the class.
---@field public self BASE Self reference.
BASE = {
    ClassName = 'BASE',
    Schedules = {}
}

--- Initialize a new instance.
---@return BASE Returns self.
function BASE:New()
    return ROUTINES.util.deepCopy(self)
end

--- Inherit a parents fields and methods to a new child object.
---@param Child table The object that inherits.
---@param Parent table The object to inherit from.
---@return BASE The new object with inherited methods.
function BASE:Inherit(Child, Parent)
    local Child = ROUTINES.util.deepCopy(Child)

    setmetatable(Child, {__index = Parent})

    return Child
end

---@return string The name of the class.
function BASE:GetClassName()
    return self.ClassName
end

---@param EventID number The event ID to handle.
---@param Callback function The function to callback on.
function BASE:HandleEvent(EventID, Callback)
    __EVENTS:_AddEvent(EventID, self, Callback)
end

--- Log a message to DCS.log (NET)
---@param msg string The message to log.
---@return BASE Returns self.
function BASE:Log(msg, ...)
    net.log(string.format('%s: %s', self:GetClassName(), string.format(msg, ...)))

    return self
end

--- Log a serialized variable to DCS.log
---@param Variable any The variable to serialize. Should be a field within a table.
---@return BASE Returns self.
function BASE:L(Variable)
    if not type(Variable) == 'table' then
        Variable = {Variable}
    end

    self:Log('%30s', ROUTINES.util.oneLineSerialize(Variable))

    return self
end

--- Get the current time.
---@return number The current time.
--function BASE:Now()
--    return timer.getTime()
--end

function BASE:SetCallbacks(Table)
    DCS.setUserCallbacks(Table)

    return self
end

function BASE:Pause()
    DCS.setPause(true)
end

function BASE:Resume()
    DCS.setPause(false)
end

function BASE:PipeUDP(Data, Port)
    local Data = ROUTINES.util.oneLineSerialize(Data)
    local Socket = require 'socket'
    local udp = assert(Socket.udp())

    udp:settimeout(0)
    udp:setpeername('localhost', Port)
    udp:send(Data)
end