local Options = {
    -- Flag to list installed modules.
    i = {
        fun = function(self) self.Mode = 'i' end,
        desc = 'Update all modules.'
    },
    -- Flag to list all modules.
    a = {
        fun = function(self) self.Mode = 'a' end,
        desc = 'Update an individual module.'
    }
}

local List = COMMAND:New('list', 'List installed or available MM modules.', Options)

function List:_List(Table)
    for Name, URL in pairs(Table) do
        self:Out('%s <%s>', Name, URL)
    end
end

function List:Execute()
    if not arg[2] then self:Help() return end

    if self.Mode == 'i' then
        if not REPOSITORIES then self:Out('No modules installed.') return end

        self:_List(REPOSITORIES)
    elseif self.Mode == 'a' then
        self:_List(_REPOSITORIES)
    end
end

return List
