---@author West#9009
---@description Event dispatching.
---@created 20MAY22

---@class EVENTS
---@type BASE
EVENTS = {
    ClassName = 'EVENTS'
}

--- Initialize a new instance.
---@return EVENTS Returns self.
function EVENTS:New()
    local self = BASE:Inherit(self, BASE:New())

    world.addEventHandler(self)

    return self
end

--- Event handler and dispatcher.
---@param Event number The event ID
function EVENTS:onEvent(Event)

    if ENUMS.EVENTS[Event.id] then

        local EventData = {}

        if Event.initiator then
            EventData.IniObjectCategory = Event.initiator:getCategory()

            if Event.IniObjectCategory == Object.Category.STATIC then
                if event.id ~= 31 and event.id ~= 33 then
                    EventData.IniDCSUnit = Event.initiator
                    EventData.IniDCSUnitName = EventData.IniDCSUnit:getName()
                    EventData.IniCoalition = EventData.IniDCSUnit:getCoalition()
                    EventData.IniCategory = EventData.IniDCSUnit:getDesc().category
                    EventData.IniTypeName = EventData.IniDCSUnit:getTypeName()
                end
            end

            if EventData.IniObjectCategory == Object.Category.UNIT then
                EventData.IniDCSUnit = Event.initiator
                EventData.IniDCSUnitName = EventData.IniDCSUnit:getName()
                EventData.IniDCSGroup = EventData.IniDCSUnit:getGroup()

                if EventData.IniDCSGroup and EventData.IniDCSGroup:isExist() then
                    EventData.IniDCSGroupName = EventData.IniDCSGroup:getName()
                    EventData.IniGroupName = EventData.IniDCSGroupName
                end

                EventData.IniPlayerName = EventData.IniDCSUnit:getPlayerName()
                EventData.IniCoalition = EventData.IniDCSUnit:getCoalition()
                EventData.IniTypeName = EventData.IniDCSUnit:getTypeName()
                EventData.IniCategory = EventData.IniDCSUnit:getDesc().category
            end

            if Event.target then
                EventData.TgtObjectCategory = Event.target:getCategory()

                if EventData.TgtObjectCategory == Object.Category.UNIT then
                    EventData.TgtDCSUnit = Event.target
                    EventData.TgtDCSGroup = EventData.TgtDCSUnit:getGroup()
                    EventData.TgtDCSUnitName = EventData.TgtDCSUnit:getName()
                    EventData.TgtDCSGroupName = ""

                    if EventData.TgtDCSGroup and EventData.TgtDCSGroup:isExist() then
                        EventData.TgtDCSGroupName = EventData.TgtDCSGroup:getName()
                    end

                    EventData.TgtPlayerName = EventData.TgtDCSUnit:getPlayerName()
                    EventData.TgtCoalition = EventData.TgtDCSUnit:getCoalition()
                    EventData.TgtCategory = EventData.TgtDCSUnit:getDesc().category
                    EventData.TgtTypeName = EventData.TgtDCSUnit:getTypeName()
                end

                if EventData.TgtObjectCategory == Object.Category.STATIC then
                    EventData.TgtDCSUnit = Event.target
                    if Event.target:isExist() and Event.id ~= 33 then
                        EventData.TgtDCSUnitName = EventData.TgtDCSUnit:getName()
                        EventData.TgtCoalition = EventData.TgtDCSUnit:getCoalition()
                        EventData.TgtCategory = EventData.TgtDCSUnit:getDesc().category
                        EventData.TgtTypeName = EventData.TgtDCSUnit:getTypeName()
                    end
                end

                if Event.TgtObjectCategory == Object.Category.SCENERY then
                    EventData.TgtDCSUnit = Event.target
                    EventData.TgtDCSUnitName = EventData.TgtDCSUnit:getName()
                    EventData.TgtCategory = EventData.TgtDCSUnit:getDesc().category
                    EventData.TgtTypeName = EventData.TgtDCSUnit:getTypeName()
                end
            end

            if Event.weapon then
                EventData.Weapon = Event.weapon
                EventData.WeaponName = EventData.Weapon:getTypeName()
            end

            if Event.place then
                if not Event.id==EVENTS.LandingAfterEjection then
                    EventData.PlaceName=Event.Place:GetName()
                end
            end

            if Event.idx then
                EventData.MarkID=Event.idx
                EventData.MarkVec3=Event.pos
                EventData.MarkText=Event.text
                EventData.MarkCoalition=Event.coalition
                EventData.MarkGroupID = Event.groupID
            end

            if Event.cargo then
                EventData.Cargo = Event.cargo
                EventData.CargoName = Event.cargo.Name
            end

            if Event.zone then
                EventData.Zone = Event.zone
                EventData.ZoneName = Event.zone.ZoneName
            end
        end

        if self._events then
            if self._events[Event.id] then
                for key, object in pairs(self._events[Event.id]) do
                    if object.callback then
                        pcall(function() object.callback(key, EventData) end)
                    end
                end
            end
        end
    else
        self:Log('warning', 'Unknown eventID = %s', Event.id)
    end
end

--- Adds an object and callback function to the event dispatching table.
---@param eventID number The event ID to handle.
---@param object table The class or object to index into dispatcher.
---@param callback function The function to call when the event occurs.
function EVENTS:AddEvent(eventID, object, callback)
    self._events = self._events or {}

    if not self._events[eventID] then
        self._events[eventID] = {}
    end

    if not self._events[eventID][object] then
        self._events[eventID][object] = {}
    end

    self._events[eventID][object]['callback'] = callback
end
