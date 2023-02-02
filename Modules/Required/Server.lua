---@author West#9009
---@description Multiple bridge module.
---@created 10JAN23

---@type BASE
SERVER = {
    ClassName = 'SERVER',
}

function SERVER:New(Port, InternetProtocol, ApplicationLayerProtocol)
    local self = BASE:Inherit(self, BASE:New())

    self.Socket = require 'socket'
    self.Port = Port

    -- Port checking
    if type(self.Port) ~= 'number' then
        self:Error('%s is not a valid port.', self.Port)

        return nil
    end

    -- Check valid port within registered port range.
    if self.Port < 1024 or self.Port > 49151 then
        self:Error('%s is not a valid port.', self.Port)

        return nil
    end

    self.Running = false
    self.Layer = false
    self.Interval = 0.02
    self.Layer = false
    self.Callbacks = {}

    if InternetProtocol == 'udp' then
        self.Protocol = 'udp'
        self.Server = self.Socket.udp()
        self.Server:setsockname('*', self.Port)
    elseif InternetProtocol == 'tcp' then
        self.Protocol = 'tcp'
        self.Server = self.Socket.tcp()
        self.Server:bind('127.0.0.1', self.Port)

        -- Turn the TCP object into a server willing to accept connections.
        self.Server:listen()

        if ApplicationLayerProtocol then
            -- eg. 'http', currently only support http 1.1
            self.Layer = ApplicationLayerProtocol

            if self.Layer == 'http' then
                self.AllowedMethods = {
                    ['GET'] = true,
                    ['HEAD'] = true,
                    ['POST'] = true
                }

                self.Status = {
                    ['Ok'] = '200 OK',
                    ['Created'] = '201 Created',
                    ['Accepted'] = '202 Accepted',
                    ['NoContent'] = '204 No Content',
                    ['BadRequest'] = '400 Bad Request',
                    ['Unauthorized'] = '401 Unauthorized',
                    ['NotFound'] = '404 Not Found',
                    ['RequestTimeout'] = '408 Request Timeout',
                    ['LengthRequired'] = '411 Length Required',
                    ['Teapot'] = "418 I'm a teapot",
                    ['TooManyRequests'] = '429 Too Many Requests',
                    ['RequestHeaderFieldsTooLarge'] = '431 Request Header Fields Too Large',
                    ['InternalServerError'] = '500 Internal Server Error',
                    ['NotImplemented'] = '501 Not Implemented'
                }

                self.Callbacks = {
                    ['GET'] = {},
                    ['POST'] = {},
                    ['HEAD'] = {}
                }

                self.HeaderLimit = 50
            end
        end
    end

    -- Don't continue if server not valid.
    if not self.Server then return nil end

    -- Either protocol must have timeout as 0 to prevent choppy frames (blocking)
    self.Server:settimeout(0)

    return self
end

function SERVER:HTTP(Port)
    return SERVER:New(Port, 'tcp', 'http')
end

function SERVER:UDP(Port)
    return SERVER:New(Port, 'udp')
end

-- Important to note, handles only one line in one callback.
function SERVER:_HandleUDP()
    local Handler = function()
        while self.Running do
            local Data = self.Server:receive()

            if not Data then coroutine.yield(); break end

            --TODO
        end
    end

    while self.Running do
        Handler()

        coroutine.yield()
    end
end

function SERVER:_HandleTCP()
    if self.Layer == 'http' then self:_HandleHTTP() return end

    --TODO
end

function SERVER:_HandleHTTP()
    local Handler = function ()
        while self.Running do
            local Client = self.Server:accept()

            if not Client then coroutine.yield(); break end

            Client:settimeout(self.Interval)

            local RequestLine = Client:receive('*l')

            local Method, Route = string.match(RequestLine, '(%a*) (.*) ')

            if not self.AllowedMethods[Method] then
                self:_Respond(Client, self:_Response(self.Status['NotImplemented'])) break
            end

            if not self.Callbacks[Method][Route] then
                self:_Respond(Client, self:_Response(self.Status['NotFound'])) break
            end

            local Headers = {}
            local HeaderLimit = false

            for i = 1, self.HeaderLimit do
                local Line = Client:receive('*l')

                if Line == '' then break end

                local Name, Value = string.match(Line, '(.*): (.*)')

                Headers[Name] = Value

                if i == self.HeaderLimit then
                    HeaderLimit = true
                end
            end

            if HeaderLimit then
                self:_Respond(Client, self:_Response(self.Status['RequestHeaderFieldsTooLarge'])) break
            end

            local Body = ''

            if not Headers['Content-Length'] then
                self:_Respond(Client, self:_Response(self.Status['LengthRequired'])) break
            end

            local ContentLength = tonumber(Headers['Content-Length'])

            local Error

            if ContentLength > 0 then
                Body, Error = Client:receive(tonumber(Headers['Content-Length']))

                if Error then
                    self:_Timeout(Client, Error) break
                end
            end

            local Media, Type

            if Headers['Content-Type'] then
                Media, Type = string.match(Headers['Content-Type'], '([^/]+)/([^/]+)')
            end

            local Callback = self.Callbacks[Method][Route]

            local Success, Result, ResponseHeaders, ResponseContentType, ResponseBody =

            pcall(Callback, {Headers = Headers, Media = Media, Type = Type, Body = Body})

            if not Success then self:_Error(Client, Result) break end

            local Response =
                self:_Response(self.Status[Result], ResponseHeaders, ResponseBody, ResponseContentType, Method)

            self:L{Response}
            local Sent, Error = self:_Respond(Client, Response)

            if not Sent then self:Error(Error) end
        end
    end

    while self.Running do
        Handler()

        coroutine.yield()
    end
end

function SERVER:AddCallback(Callback, Method, Route)
    if self.Layer == 'http' then
        self.Callbacks[Method][Route] = Callback
    end
end

function SERVER:GET(Route, Callback)
    if not self.Protocol == 'tcp' then return end
    if not self.Layer == 'http' then return end

    self:AddCallback(Callback, 'GET', Route)
    self:AddCallback(Callback, 'HEAD', Route)

    return self
end

function SERVER:POST(Route, Callback)
    if not self.Protocol == 'tcp' then return end
    if not self.Layer == 'http' then return end

    self:AddCallback(Callback, 'POST', Route)

    return self
end

function SERVER:_Error(Client, Message)
    return self:_Respond(Client, self:_Response(self.Status['InternalServerError'], nil, Message))
end

function SERVER:_Timeout(Client, Message)
    return self:_Respond(Client, self:_Response(self.Status['RequestTimeout'], nil, Message))
end

function SERVER:_Response(Status, Headers, Body, ContentType, Method)
    local Body = Body or 'No Content'
    local ContentType = ContentType or 'text/plain'
    local Method = Method or nil
    local Headers = Headers or {}

    Headers['Content-Length'] = string.len(Body)
    Headers['Content-Type'] = ContentType or 'text/plain'
    Headers['Server'] = 'MSF (West#9009)'

    local Response = string.format('HTTP/1.1 %s\r\n', Status)

    for Key, Value in pairs(Headers) do
        Response = string.format('%s%s: %s\r\n', Response, Key, Value)
    end

    Response = string.format('%sContent-Type: %s\r\n', Response, ContentType)

    local ContentLength = string.len(Body)

    Response = string.format('%sContent-Length: %s\r\n\n', Response, ContentLength)

    if Method == 'HEAD' then return Response end

    Response = string.format('%s\r\n%s', Response, Body)

    return Response
end

function SERVER:_Respond(Client, Response)
    local Sent, Error = Client:send(Response)

    Client:close()

    if Sent then return Sent end

    return Error
end

function SERVER:Start()
    self.Running = true

    local Handlers = {
        ['udp'] = self._HandleUDP,
        ['tcp'] = self._HandleTCP
    }

    self.co = coroutine.create(Handlers[self.Protocol])
    coroutine.resume(self.co, self)

    self.Scheduler = self:ScheduleRepeat(self.Interval, coroutine.resume, self.co, self)

    return self
end

function SERVER:IsRunning()
    return self.Running
end

function SERVER:Stop()
    self.Running = false
    self:ScheduleStop(self.Scheduler)
end
