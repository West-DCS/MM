local Update = COMMAND:New()

function Update:Execute(Args)
    if not Args[2] then self:Help() return end
    if not REPOSITORIES then self:Out('Nothing to update. Add a module with "add <Name>"') return end

    local Flag = Args[2]

    -- Update all repositories.
    if Flag == '-a' then
        for Repo, _ in pairs(REPOSITORIES) do
            local Path = _MSF.OptionalDirectory .. Repo

            ROUTINES.git.update(Path)
        end
    -- Update an individual repository.
    elseif Flag == '-i' then
        local Repo = arg[3]

        if not REPOSITORIES[Repo] then self:Out('Module %s not indexed, cannot update.', Repo) return end

        local Path = _MSF.OptionalDirectory .. Repo

        ROUTINES.git.update(Path)
    else
        self:Help()
    end
end

function Update:Help()
    self:Out('Usage: update')
    self:Out('\t[-i] <module>\tUpdate a specific module.')
    self:Out('\t[-a]\t\tUpdate all modules.')
end

return Update
