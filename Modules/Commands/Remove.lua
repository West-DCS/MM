local Remove = COMMAND:New()

function Remove:Execute(Args)
    if not Args[2] then self:Help() return end
    if not REPOSITORIES then self:Out('Nothing to remove.') return end

    local Name = Args[2]

    if Name == '-help' then self:Help() return end
    if not REPOSITORIES[Name] then self:Out('Module does not exist.') return end

    REPOSITORIES[Name] = nil

    ROUTINES.file.EDSerializeToFile(_MSF.ConfigDirectory, 'REPOSITORIES', REPOSITORIES)

    local dir = string.format('%s%s', _MSF.OptionalDirectory, Name)

    ROUTINES.os.rmdir(dir)

    self:Out('%s was removed.', Name)
end

function Remove:Help()
    self:Out('Usage: remove <Module>\tRemove a module.')
end

return Remove
