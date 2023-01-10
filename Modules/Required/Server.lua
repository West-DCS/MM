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

    return self
end

function SERVER:Start(Object, Callback)
    self.Continue = true

    self.co = coroutine.create(function()
        while self.Continue do
            local Data = self.udp:receive()

            if Data then
                Callback(Object, Data)

                coroutine.yield()
            else
                coroutine.yield()
            end
        end
    end)

    coroutine.resume(self.co, self)

    self:ScheduleRepeat(1/2000, coroutine.resume, self.co, self)

end

function SERVER:Stop()
    self.Continue = false
end
