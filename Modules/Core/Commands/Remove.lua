local Remove = COMMAND:New('remove', 'Remove a module from MM.')

function Remove:Execute()
    if not arg[2] then self:Help() return end
    if not REPOSITORIES then self:Out('Nothing to remove.') return end

    local Name = arg[2]

    if not REPOSITORIES[Name] then self:Out('Module does not exist.') return end

    local Init = _MM:TryLoadStringOrFile({_MM.CommunityDirectory .. 'Init.lua'}, true)

    for i, InitName in ipairs(Init) do
        if InitName == Name then
            Init[i] = nil
        end
    end

    ROUTINES.file.EDSerializeToFile(_MM.CommunityDirectory, 'Init', Init, '.lua', true)

    REPOSITORIES[Name] = nil

    ROUTINES.file.EDSerializeToFile(_MM.ConfigDirectory, 'REPOSITORIES', REPOSITORIES)

    local dir = string.format('%s%s', _MM.CommunityDirectory, Name)

    ROUTINES.os.rmdir(dir)

    self:Out('%s was removed.', Name)
end

function Remove:Help()
    self:Out('Usage: remove <Module>\tRemove a module.')
end

return Remove
