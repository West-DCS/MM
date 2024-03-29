local Install = COMMAND:New('install', 'Install a community module from GitHub.')

-- Fix this later
--function Install:_Hooks()
--    local Source = string.format('%sMSFGameGui.lua', _MM.Directory)
--    local Destination = string.format('%s\\Scripts\\Hooks\\%sGameGui.lua',
--            CONFIG.SavedGames,
--            CONFIG.ProjectName)
--
--    local Contents = ROUTINES.file.read(Source, '')
--    local NewPath = string.format([[\%s\]], CONFIG.ProjectName)
--    local DirSub = string.gsub(Contents, '\\$\\', NewPath)
--    local NameSub = string.gsub(DirSub, '#', CONFIG.ProjectName)
--
--    ROUTINES.file.write(Destination, '', NameSub)
--end

function Install:Execute()
    if not arg[2] then self:Help() return end
    if not _REPOSITORIES then self:Out('Could not fetch module from GitHub.') return end
    if not REPOSITORIES then REPOSITORIES = {} end

    local Name = arg[2]

    local Repository
    local Destination
    local URL

    if REPOSITORIES[Name] then self:Out('%s already exists. Run update -i %s instead.', Name, Name) return end

    Repository = _REPOSITORIES[Name]

    if Repository then
        Destination = _MM.CommunityDirectory .. Name
        URL = Repository
    else
        if not arg[3] then self:Out('%s is not indexed, you must provide a URL as a third argument.', Name) return end

        URL = arg[3]
        Destination = _MM.CommunityDirectory .. Name
    end

    local status = ROUTINES.git.clone(URL, Destination)

    if status ~= 0 then self:Out('An error occurred when trying to download the module. Code %s', status) return end

    REPOSITORIES[Name] = URL
    ROUTINES.file.EDSerializeToFile(_MM.ConfigDirectory, 'REPOSITORIES', REPOSITORIES)

    local Init = _MM:TryLoadStringOrFile({_MM.CommunityDirectory .. 'Init.lua'}, true)

    if not Init then Init = {} end

    if Name == CONFIG.AutoPriority then
        table.insert(Init, 1, Name)
    else
        table.insert(Init, Name)
    end

    ROUTINES.file.EDSerializeToFile(_MM.CommunityDirectory, 'Init', Init, '.lua', true)

    self:Out('%s was added.', Name)
end

function Install:Help()
    self:Out('Usage: install <Module> <URL>\tAdd a module. URL only required for non-listed modules.')
end

return Install
