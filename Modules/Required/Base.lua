---@author West#9009
---@description Base object in which child objects are derived. Includes functions for logging.
---@created 16MAY22

---@class BASE
---@field public BASE table Public methods and fields.
---@field public ClassName string The name of the class.
---@field public self BASE Self reference.
BASE = {
    ClassName = 'BASE',
    Schedules = {},
    Listeners = {}
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

---@param Repeat number How many seconds until callback function is run, and how many seconds thereafter.
---@param Callback function The function to callback on.
---@return function Returns a function to serve as the ID of the scheduler.
function BASE:ScheduleRepeat(Repeat, Callback, ...)
    self.Schedules[Callback] = true

    timer.scheduleFunction(function(Table, Time)
        if not self.Schedules[Callback] then return nil end

        local callback = Table[1]
        local args = Table[2]

        callback(args)

        return Time + Repeat

    end, { Callback, ... }, self:Now() + Repeat)

    return Callback
end

---@param ScheduleID function The function to stop.
function BASE:ScheduleStop(ScheduleID)
    if self.Schedules[ScheduleID] then
        self.Schedules[ScheduleID] = nil
    end

    return self
end

--- Stop all scheduled functions in this class.
function BASE:ScheduleStopAll()
    for key, _ in pairs(self.Schedules) do
        self.Schedules[key] = nil
    end

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
    self:Log(msg, 'info', ...)

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

    self:Info('%30s', ROUTINES.util.oneLineSerialize(Variable))

    return self
end

--- Create a remove event to handle.
---@param Time number The time the event occurred.
---@param Initiator table The object that initiated the event.
function BASE:CreateEventRemoveUnit(Time, Initiator)
    local Event = {
        id = ENUMS.EVENTS.RemoveUnit,
        time = Time,
        initiator = Initiator
    }

    world.onEvent(Event)

    return self
end

--- Get the current time.
---@return number The current time.
function BASE:Now()
    return timer.getTime()
end

function BASE:AddListener(Port, Callback)
    self.Listeners[Port] = SERVER:New(Port)

    self.Listeners[Port]:Start(self, Callback)

    self:Info(string.format('Listener added on port %s.', Port))

    return Port
end

function BASE:RemoveListener(Port)
    self.Listeners[Port]:Stop()

    self.Listeners[Port] = nil

    return self
end

function BASE:RemoveAllListeners()
    for _, Listener in pairs(self.Listeners) do
        Listener:Stop()
    end

    self.Listeners = {}

    return self
end
