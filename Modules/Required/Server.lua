---@author West#9009
---@description Server UDP Socket module.
---@created 10JAN23

---@type BASE
SERVER = {
    ClassName = 'SERVER',
}

function SERVER:New(Port)
    local self = BASE:Inherit(self, BASE:New())

    self.Socket = require('socket')
    self.Port = Port
    self.udp = assert(self.Socket.udp())
    self.udp:settimeout(0)
    self.udp:setsockname('*', self.Port)

    self.Running = true

    return self
end

function SERVER:NewTCP(Port)
    local self = BASE:Inherit(self, BASE:New())

    self.Socket = require('socket')
    self.Port = Port

    self.Running = true

    return self
end

function SERVER:Start(Object, Callback)
    self.co = coroutine.create(function()
        while self.Running do
            local Data = self.udp:receive()

            if Data then
                Data = NET:JSON2LUA(Data)

                Callback(Object, Data)
            else
                coroutine.yield()
            end
        end
    end)

    coroutine.resume(self.co, self)

    self:ScheduleRepeat(2/1000, coroutine.resume, self.co, self)
end

function SERVER:StartTCP(Object, Callback)
    self.Server = self.Socket.tcp()
    self.Server:settimeout(0)
    self.Server:bind("*", self.Port)
    self.Server:listen()

    self.co = coroutine.create(function()
        while self.Running do
            local Client = self.Server:accept()

            if Client then
                self:Info('Client Detected.')

                local Data, Error = Client:receive()

                if not Error then
                    self:L{Data}
                    --Data = NET:JSON2LUA(Data)

                    while true do
                        local Sent = Client:send('Accepted\n')

                        if Sent then break end

                        coroutine.yield()
                    end

                    --Callback(Object, Data)
                end

                Client:close()
            else
                self:Info('No Client Detected.')
                coroutine.yield()
            end
        end
    end)

    coroutine.resume(self.co, self)

    self.Scheduler = self:ScheduleRepeat(0.02, coroutine.resume, self.co, self)
end

function SERVER:Stop()
    self.Running = false
    self:ScheduleStop(self.Scheduler)
end

TCP = SERVER:NewTCP(101):StartTCP(TCP, function(Data) self:L(Data) end)