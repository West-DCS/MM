---@author West#9009
---@description Event dispatching. Based in part from MOOSE.
---@created 20MAY22

---@class EVENTS
EVENTS = {
    ClassName = 'EVENTS',
    Chat = {}
}

--- Initialize a new instance.
---@type BASE
---@return EVENTS Returns self.
function EVENTS:New()
    local self = BASE:Inherit(self, BASE:New())

    return self
end

function EVENTS:onPlayerTrySendChat(Object, Callback)
    local table = {}

    function table.onPlayerTrySendChat(PlayerId, Message, All)
        local Event = {}

        Event.PlayerID = PlayerId
        Event.Message = Message
        Event.All = All

        Event = self:_AddEventData(Event)

       return Callback(Object, Event)
    end

    self:SetCallbacks(table)
end

function EVENTS:onMissionLoadEnd(Object, Callback)
    local table = {}

    function table.onMissionLoadEnd()
        local Event = {}

        Event.MissionName = self:GetMissionName()
        Event.IsPause = self:IsPause()

        return Callback(Object, Event)
    end

    self:SetCallbacks(table)
end

function EVENTS:_AddEventData(Event)
    if not Event.PlayerID then return Event end

    local NetPlayersInfo = NET:GetAllPlayersInfoID()

    local PlayerData = NetPlayersInfo[Event.PlayerID]

    if not PlayerData then return Event end

    Event.PlayerName = PlayerData.Name
    Event.Coalition = PlayerData.Coalition
    Event.SlotID = PlayerData.SlotID
    Event.Ping = PlayerData.Ping
    Event.ip = PlayerData.ip
    Event.ucid = PlayerData.ucid

    return Event
end

function EVENTS:_AddEvent(EventType, Object, Callback)
    local EventTypes = {
        Chat = self.onPlayerTrySendChat,
        Load = self.onMissionLoadEnd
    }

    if not EventTypes[EventType] then return end

    EventTypes[EventType](self, Object, Callback)

    return self
end

__EVENTS = EVENTS:New()
