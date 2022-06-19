---@author West#9009
---@description Messenger functions
---@created 19JUN22

---@type BASE
---@class MESSAGE
MESSAGE = {
    ClassName = 'MESSAGE'
}

--- Instantiate a new Message object.
---@param Message string The message to be sent.
---@param DefaultTime number The amount of time a message will last.
---@param Prefix string The prefix to adjoin the the message. eg 'Test: msg....' where the prefix is 'Test'
---@param Clear boolean True: The message clear as soon as time is up. False: The message will fade.
---@return self
function MESSAGE:New(Message, DefaultTime, Prefix, Clear)
    if not Message then return end

    local self = BASE:Inherit(self, BASE:New())

    self.Message = Message
    self.Time = DefaultTime or 10
    self.Clear = Clear or false

    if Prefix then
        self.Prefix = Prefix
        self.Message = self:_AdjoinPrefix(self.Message)
    end

    return self
end

--- Internal function to adjoin a prefix to a string.
---@param String string The String to append to self.Prefix
---@return string
function MESSAGE:_AdjoinPrefix(String)
    if not String then return end
    if not type(String) == 'string' then return end
    if not self.Prefix then return String end

    return string.format('%s: %s', self.Prefix, String)
end

--- Set the message Prefix
---@param Prefix string The prefix to adjoin to messages.
---@return self
function MESSAGE:SetPrefix(Prefix)
    if not type(Prefix) == 'string' or not Prefix == nil then return end

    self.Prefix = Prefix

    return self
end

--- Send the message to a specific unit.
---@param Unit table The Unit wrapper object.
---@param Time number Optional. Override time to a set time.
---@param Clear boolean Optional. Override Clear to true or false.
---@param Message string Optional. Override message to a different message.
---@return self
function MESSAGE:ToUnit(Unit, Time, Clear, Message)
    if not Unit.GetClassName then return end
    if not Unit:GetClassName() == 'UNIT' then return end

    local ID = Unit:GetID()
    Time = Time or 10
    Message = self:_AdjoinPrefix(Message) or self.Message
    Clear = Clear or self.Clear

    trigger.action.outTextForUnit(ID, Message, Time, Clear)

    return self
end

--- Send the message to a specific group.
---@param Group table The Group wrapper object.
---@param Time number Optional. Override time to a set time.
---@param Clear boolean Optional. Override Clear to true or false.
---@param Message string Optional. Override message to a different message.
---@return self
function MESSAGE:ToGroup(Group, Time, Clear, Message)
    if not Group.GetClassName then return end
    if not Group:GetClassName() == 'GROUP' then return end

    local ID = Group:GetID()
    Time = Time or self.Time
    Message = self:_AdjoinPrefix(Message) or self.Message
    Clear = Clear or self.Clear

    trigger.action.outTextForGroup(ID, Message, Time, Clear)

    return self
end

--- Send the message to a specific country.
---@param CountryID number The country ID.
---@param Time number Optional. Override time to a set time.
---@param Clear boolean Optional. Override Clear to true or false.
---@param Message string Optional. Override message to a different message.
---@return self
function MESSAGE:ToCountry(CountryID, Time, Clear, Message)
    if not type(CountryID) == 'number' then return end

    Time = Time or self.Time
    Message = self:_AdjoinPrefix(Message) or self.Message
    Clear = Clear or self.Clear

    trigger.action.outTextForCountry(CountryID, Message, Time, Clear)
end

--- Send the message to a specific country.
---@param CoalitionEnum number The coalition ID.
---@param Time number Optional. Override time to a set time.
---@param Clear boolean Optional. Override Clear to true or false.
---@param Message string Optional. Override message to a different message.
---@return self
function MESSAGE:ToCoalition(CoalitionEnum, Time, Clear, Message)
    if not type(CoalitionEnum) == 'number' then return end

    Time = Time or self.Time
    Message = self:_AdjoinPrefix(Message) or self.Message
    Clear = Clear or self.Clear

    trigger.action.outTextForCoalition(CoalitionEnum, Message, Time, Clear)
end

--- Send the message to everyone.
---@param Time number Optional. Override time to a set time.
---@param Clear boolean Optional. Override Clear to true or false.
---@param Message string Optional. Override message to a different message.
---@return self
function MESSAGE:ToAll(Time, Clear, Message)
    Time = Time or self.Time
    Message = self:_AdjoinPrefix(Message) or self.Message
    Clear = Clear or self.Clear

    trigger.action.outText(Message, Time, Clear)
end
