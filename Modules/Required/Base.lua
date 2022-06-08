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

---@param EventID number The event ID to handle.
---@param Callback function The function to callback on.
function BASE:HandleEvent(EventID, Callback)
    __EVENTS:AddEvent(EventID, self, Callback)
end

---@param Seconds number How many seconds until callback function.
---@param Callback function The function to callback on.
function BASE:Schedule(Seconds, Callback, ...)
    timer.scheduleFunction(Callback, ..., timer.getTime() + Seconds)

    return self
end

--- Log a message to DCS.log
---@param logType string info, warning, error
---@param msg string The message to log.
---@return BASE Returns self.
function BASE:Log(msg, logType, ...)
    logType = logType or 'info'

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

--- Log an info message to DCS.log
---@param msg string The message to log.
---@return BASE Returns self.
function BASE:Info(msg, ...)
    self:Log(msg, nil, ...)

    return self
end

--- Log an error message to DCS.log
---@param msg string The message to log.
---@return BASE Returns self.
function BASE:Error(msg, ...)
    self:Log(msg, 'error', ...)

    return self
end

--- Log a warning message to DCS.log
---@param msg string The message to log.
---@return BASE Returns self.
function BASE:Warning(msg, ...)
    self:Log(msg, 'warning', ...)

    return self
end

--- Log a serialized variable to DCS.log
---@param Variable any The variable to serialize. Should be a field within a table.
---@return BASE Returns self.
function BASE:L(Variable)
    if not type(Variable) == 'table' then
        Variable = {Variable}
    end

    self:Log('info', '%30s', ROUTINES.util.oneLineSerialize(Variable))

    return self
end
