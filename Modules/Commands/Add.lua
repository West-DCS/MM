local Add = COMMAND:New()

function Add:_Hooks()
    local Source = string.format('%sMSFGameGui.lua', _MSF.Directory)
    local Destination = string.format('%s\\Scripts\\Hooks\\%sGameGui.lua',
            CONFIG.SavedGames,
            CONFIG.ProjectName)

    local Contents = ROUTINES.file.read(Source, '')
    local NewPath = string.format([[\%s\]], CONFIG.ProjectName)
    local DirSub = string.gsub(Contents, '\\$\\', NewPath)
    local NameSub = string.gsub(DirSub, '#', CONFIG.ProjectName)

    ROUTINES.file.write(Destination, '', NameSub)
end

function Add:Execute(Args)
    if not Args[2] then self:Help() return end
    if not _REPOSITORIES then self:Out('Could not fetch module from GitHub.') return end
    if not REPOSITORIES then REPOSITORIES = {} end

    local Name = arg[2]

    if Name == '-help' then self:Help() return end
    if Name == 'hooks' then self:_Hooks() return end

    local Repository
    local Destination
    local URL

    if REPOSITORIES[Name] then self:Out('%s already exists. Run update -i %s instead.', Name, Name) return end

    Repository = _REPOSITORIES[Name]

    if Repository then
        Destination = _MSF.OptionalDirectory .. Name
        URL = Repository
    else
        if not arg[3] then self:Out('%s is not indexed, you must provide a URL as a third argument.', Name) return end

        URL = arg[3]
        Destination = _MSF.OptionalDirectory .. Name
    end

    local status = ROUTINES.git.clone(URL, Destination)

    if status ~= 0 then self:Out('An error occurred when trying to download the module. Code %s', status) return end

    REPOSITORIES[Name] = URL
    ROUTINES.file.EDSerializeToFile(_MSF.ConfigDirectory, 'REPOSITORIES', REPOSITORIES)
    self:Out('%s was added.', Name)
end

function Add:Help()
    self:Out('Usage: add <Module> <URL>\tAdd a module. URL only required for non-listed modules.')
end

return Add
