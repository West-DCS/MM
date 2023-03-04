local List = COMMAND:New()

function List:_List(Table)
    self:Out('Modules\n')

    for Name, URL in pairs(Table) do
        self:Out('%s <%s>', Name, URL)
    end
end

function List:Execute(Args)
    if not Args[2] then self:Help() return end

    local Flag = Args[2]

    if Flag == '-i' then
        if not REPOSITORIES then self:Out('No modules installed.') return end

        self:_List(REPOSITORIES)
    elseif Flag == '-a' then
        if not _REPOSITORIES then self:Out('Could not fetch modules from GitHub.') return end

        self:_List(_REPOSITORIES)
    else
        self:Help()
    end
end

function List:Help()
    self:Out('Usage: list')
    self:Out('\t[-i]\tList installed modules.')
    self:Out('\t[-a]\tList available modules.')
end

return List
