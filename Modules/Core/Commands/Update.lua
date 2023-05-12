local Options = {
    -- Flag to update all modules.
    a = {
        fun = function(self) self.Mode = 'a' end,
        desc = 'Update all modules.'
    },
    -- Flag to update a specific module
    i = {
        fun = function(self, Param) self.Mode = 'i'; self.Module = Param end,
        desc = 'Update an individual module.',
        param = 'Module'
    }
}

local Update = COMMAND:New('update', 'Update community modules.', Options)

function Update:Execute()
    if not arg[2] then self:Help() return end
    if not REPOSITORIES then self:Out('Nothing to update. Add a module with "add <Name>"') return end

    -- Update all repositories.
    if self.Mode == 'a' then
        for Repo, _ in pairs(REPOSITORIES) do
            local Path = _MM.OptionalDirectory .. Repo

            ROUTINES.git.update(Path)
        end
    -- Update an individual repository.
    elseif self.Mode == 'i' then
        if not self.Module then self:Out('You must provide a module to update or use -a instead to update everything.')
            return
        end

        if not REPOSITORIES[self.Module] then self:Out('Module %s not indexed, cannot update.', self.Module) return end

        local Path = _MM.OptionalDirectory .. self.Module

        ROUTINES.git.update(Path)
    end
end

return Update
