---@author West#9009
---@description Mission NET module.
---@created 01JAN23

---@type BASE
NET = {
    ClassName = 'NET'
}

function NET:_New()
    local self = BASE:Inherit(self, BASE:New())

    return self
end

function NET:GetNameFromPlayerID(id)
    local name = net.get_name(id)

    if name then return name end

    return nil
end

function NET:GetPlayerIDFromName(Name)
    local NetPlayersInfo = self:GetAllPlayersInfo()

    local PlayerID = NetPlayersInfo[Name].PlayerID

    if PlayerID then return PlayerID end

    return nil
end

function NET:GetCoalitionFromPlayerID(id)
    local coalition = net.get_player_info(id, 'side')

    if coalition then return coalition end

    return nil
end

function NET:GetSlotIDFromPlayerID(id)
    local slot = net.get_player_info(id, 'slot')

    if slot then return slot end

    return nil
end

function NET:ForceSlotByPlayerID(id, SideID, SlotID)
    net.force_player_slot(id, SideID, SlotID)

    return self
end

function NET:GetPingFromPlayerID(id)
    local ping = net.get_player_info(id, 'ping')

    if ping then return ping end

    return nil
end

function NET:GetIPFromPlayerID(id)
    local ip = net.get_player_info(id, 'ipaddr')

    if ip then return ip end

    return nil
end

function NET:GetUCIDFromPlayerID(id)
    local ucid = net.get_player_info(id, 'ucid')

    if ucid then return ucid end

    return nil
end

function NET:GetPlayerIDFromUCID(ucid)
    local NetPlayersInfo = self:_GetAllPlayersInfoUCID()

    local id = NetPlayersInfo[ucid].PlayerID

    if id then return id end

    return nil
end

function NET:KickByPlayerID(PlayerID, Message)
    net.kick(PlayerID, Message or nil)

    return self
end

function NET:KickByUCID(ucid, Message)
    local PlayerID = self:GetPlayerIDFromUCID(ucid)

    self:KickByPlayerID(PlayerID, Message or nil)

    return self
end

function NET:KickToSpectatorsByPlayerID(PlayerID, Message)
    self:ForceSlotByPlayerID(PlayerID, 0, '')

    if Message then
        self:SendChat(Message)
    end

    self:Info('Kicked %s back to spectators.', PlayerID)

    return self
end

function NET:KickToSpectatorsByUCID(ucid, Message)
    local PlayerID = self:GetPlayerIDFromUCID(ucid)

    if not PlayerID then return end

    self:KickToSpectatorsByPlayerID(PlayerID, Message)

    return self
end

function NET:GetAllPlayersInfo()
    local PlayerList = net.get_player_list()
    local PlayersInfo = {}

    for _, id in ipairs(PlayerList) do
        local PlayerInfo = net.get_player_info(id, nil)

        PlayersInfo[PlayerInfo.name] = {
            PlayerID = id,
            Name = PlayerInfo.name,
            Coalition = PlayerInfo.side,
            SlotID = PlayerInfo.slot,
            Ping = PlayerInfo.ping,
            ip = PlayerInfo.ipaddr,
            ucid = PlayerInfo.ucid
        }

    end

    return PlayersInfo
end

function NET:GetAllPlayersInfoID()
    local PlayerList = net.get_player_list()
    local PlayersInfo = {}

    for _, id in ipairs(PlayerList) do
        local PlayerInfo = net.get_player_info(id, nil)

        PlayersInfo[id] = {
            PlayerID = id,
            Name = PlayerInfo.name,
            Coalition = PlayerInfo.side,
            SlotID = PlayerInfo.slot,
            Ping = PlayerInfo.ping,
            ip = PlayerInfo.ipaddr,
            ucid = PlayerInfo.ucid
        }

    end

    return PlayersInfo
end

function NET:_GetAllPlayersInfoUCID()
    local PlayerList = net.get_player_list()
    local PlayersInfo = {}

    for _, id in ipairs(PlayerList) do
        local PlayerInfo = net.get_player_info(id, nil)

        PlayersInfo[PlayerInfo.ucid] = {
            PlayerID = id,
            Name = PlayerInfo.name,
            Coalition = PlayerInfo.side,
            SlotID = PlayerInfo.slot,
            Ping = PlayerInfo.ping,
            ip = PlayerInfo.ipaddr,
            ucid = PlayerInfo.ucid
        }

    end

    return PlayersInfo
end

function NET:SendChat(Message, To, From)
    if not To then net.send_chat(Message) return end
    if To and not From then From = To end

    local ToPlayerID = nil
    local FromPlayerID = nil

    if type(To) == 'string' then
        -- If UCID
        if string.len(To) == 32 then
            ToPlayerID = self:GetPlayerIDFromUCID(To)

            -- If a players name happens to be 32 characters long.
            if not ToPlayerID then
                ToPlayerID = self:GetPlayerIDFromName(To)
            end
        end

        -- If not UCID (A Name with a string length not equal to 32)
        if string.len(To) ~= 32 then
            ToPlayerID = self:GetPlayerIDFromName(To)
        end

    elseif type(To) == 'Number' then
        ToPlayerID = To
    end

    if type(From) == 'string' then
        -- If UCID
        if string.len(From) == 32 then
            FromPlayerID = self:GetPlayerIDFromUCID(From)

            -- If a players name happens to be 32 characters.
            if not FromPlayerID then
                FromPlayerID = self:GetPlayerIDFromName(From)
            end
        end

        -- If not UCID (A Name with a string length not equal to 32)
        if string.len(From) ~= 32 then
            FromPlayerID = self:GetPlayerIDFromName(From)
        end
    elseif type(From) == 'Number' then
        FromPlayerID = From
    end

    net.send_chat_to(Message, ToPlayerID, FromPlayerID)

    return self
end

function NET:JSON2LUA(JSON)
    return net.json2lua(JSON)
end

NET = NET:_New()
