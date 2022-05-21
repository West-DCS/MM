---@author West#9009
---@description Base object in which child objects are derived. Includes functions for logging.
---@created 16MAY22

---@class BASE
---@field public BASE table Public methods and fields.
---@field public ClassName string The name of the class.
---@field public self BASE Self reference.
BASE = {
    ClassName = 'BASE'
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

function BASE:HandleEvent(eventID, callback)
    __EVENTS:AddEvent(eventID, self, callback)
end

--- Log a message to DCS.log
---@param logType string info, warning, error
---@param msg string The message to log.
---@return BASE Returns self.
function BASE:Log(logType, msg, ...)
    local write = function(logType, ...)
        logType(string.format('%s: %s', self:GetClassName(), string.format(msg, ...)))
    end

    local logTypes = {
        info = env.info,
        warning = env.warning,
        error = env.error
    }

    write(logTypes[logType], ...)

    return self
end
