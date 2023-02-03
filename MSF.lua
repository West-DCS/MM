---@author West#9009
---@description Mission Scripting Framework. Initialization functions.
---@created 16MAY22

do
    _MSF = {}

    local soft

    if arg then
        lfs = require 'lfs'

        soft = arg[1]

        _MSF.Directory = lfs.currentdir() .. [[\]]
    else
        _MSF.Directory = lfs.writedir() .. string.format([[Scripts\%s\]], CONFIG.ProjectName)
    end

    _MSF.ModulesDirectory = _MSF.Directory .. [[Modules\]]
    _MSF.UserDirectory = _MSF.ModulesDirectory .. [[User\]]
    _MSF.OptionalDirectory = _MSF.ModulesDirectory .. [[Optional\]]
    _MSF.RequiredDirectory = _MSF.ModulesDirectory .. [[Required\]]
    _MSF.ObjectsDirectory = _MSF.RequiredDirectory .. [[Objects\]]
    _MSF.ConfigDirectory = _MSF.Directory .. [[Config\]]

    if not soft then
        package.path  = package.path .. ";.\\LuaSocket\\?.lua"

        function _MSF:Load(File, Explicit)
            local location = self.UserDirectory .. File

            if Explicit then
                local locations = {
                    Optional = self.OptionalDirectory,
                    Required = self.RequiredDirectory,
                    Objects = self.ObjectsDirectory,
                    Config = self.ConfigDirectory
                }

                if locations[Explicit] then
                    location = locations[Explicit] .. File
                else
                    location = File
                end
            end

            local f, err = loadfile(location)

            if not f then
                env.error('Error in file: ' .. File)
                env.error(err)
            else
                return f()
            end
        end

        -- Load MSF Modules
        dofile(_MSF.Directory .. 'Modules.lua')

        -- Load Optional Modules
        if REPOSITORIES then
            for module, _ in pairs(REPOSITORIES) do
                _MSF:Load(string.format([[%s\Module.lua]], module), 'Optional')
            end
        end

        -- Load User Modules (non-recursively, unordered)
        for file in lfs.dir(_MSF.UserDirectory) do
            if ROUTINES.file.isFile(_MSF.UserDirectory .. file) then
                BASE:Info('Loading: %s', file)
                _MSF:Load(file)
            end
        end

        -- Log certifies that at least all modules loaded.
        BASE:Info('%s initialization finished.', CONFIG.ProjectName)
    else
        function _MSF.Load(File)
            local f = loadfile(File)

            if f then
                return f()
            end
        end

        function _MSF.FetchRepositories()
            local header = '"Accept:application/vnd.github.v3.raw"'
            local link = 'https://api.github.com/repos/nicelym/MSF_Repositories/contents/REPOSITORIES'
            local argument = string.format("%s %s", header, link)

            return ROUTINES.os.capture(string.format('curl -s -H %s', argument))
        end

        --Load Config file
        _MSF.Load(_MSF.ConfigDirectory .. 'Config.lua')

        -- Load Routines for external use.
        _MSF.Load(_MSF.RequiredDirectory .. 'Routines.lua')
        _MSF.Load(_MSF.ConfigDirectory .. 'REPOSITORIES')

        local f = assert(loadstring(_MSF.FetchRepositories()))

        if f then
            f()
        end

        if soft == 'add' then
            local usage = function()
                print('Usage: add <Module> <URL>\tAdd a module. URL only required for non-listed modules.')
            end

            if not arg[2] then usage() return end
            if not _REPOSITORIES then print('Could not fetch module from GitHub.') return end
            if not REPOSITORIES then REPOSITORIES = {} end

            local Name = arg[2]

            if Name == '-help' then
                usage()

                return
            end

            if Name == 'hooks' then
                local Source = string.format('%sMSFGameGui.lua', _MSF.Directory)
                local Destination = string.format('%s\\Scripts\\Hooks\\%sGameGui.lua',
                        CONFIG.SavedGames,
                        CONFIG.ProjectName)

                local Contents = ROUTINES.file.read(Source, '')
                local NewPath = string.format([[\%s\]], CONFIG.ProjectName)
                local DirSub = string.gsub(Contents, '\\$\\', NewPath)
                local NameSub = string.gsub(DirSub, '#', CONFIG.ProjectName)

                ROUTINES.file.write(Destination, '', NameSub)

                return
            end

            local Repository
            local Destination
            local URL

            if REPOSITORIES[Name] then
                print(string.format('%s already exists. Run update -i %s instead.', Name, Name))
                return
            end

            Repository = _REPOSITORIES[Name]

            if Repository then
                Destination = _MSF.OptionalDirectory .. Name
                URL = Repository
            else
                if not arg[3] then
                    print(string.format('%s is not indexed, you must provide a URL as a third argument.',
                            Name))
                    return
                end

                URL = arg[3]
                Destination = _MSF.OptionalDirectory .. Name
            end

            local status = ROUTINES.git.clone(URL, Destination)

            if status == 0 then
                REPOSITORIES[Name] = URL

                ROUTINES.file.EDSerializeToFile(_MSF.ConfigDirectory, 'REPOSITORIES', REPOSITORIES)
                print(string.format('%s was added.', Name))
            else
                print(string.format('An error occurred when trying to download the module. Code %s',
                        status))
            end
        elseif soft == 'update' then
            local usage = function()
                print('Usage: update')
                print('\t[-i] <module>\tUpdate a specific module.')
                print('\t[-a]\t\tUpdate all modules.')
            end

            if not arg[2] then usage() return end

            local flag = arg[2]

            if REPOSITORIES then
                -- Update all repositories.
                if flag == '-a' then
                    for repo, _ in pairs(REPOSITORIES) do
                        local path = _MSF.OptionalDirectory .. repo

                        ROUTINES.git.update(path)
                    end
                    -- Update an individual repository.
                elseif flag == '-i' then
                    local repo = arg[3]

                    if REPOSITORIES[repo] then
                        local path = _MSF.OptionalDirectory .. repo

                        ROUTINES.git.update(path)
                    else
                        print('Module not indexed, cannot update.')
                    end
                else
                    usage()
                end
            else
                print('Nothing to update. Add a module with "add <Name>"')
            end
        elseif soft == 'remove' then
            local usage = function()
                print('Usage: remove <Module>\tRemove a module.')
            end

            if not arg[2] then usage() return end

            local Name = arg[2]

            if Name == '-help' then
                usage()

                return
            end

            if REPOSITORIES then
                if REPOSITORIES[Name] then
                    REPOSITORIES[Name] = nil

                    ROUTINES.file.EDSerializeToFile(_MSF.ConfigDirectory, 'REPOSITORIES', REPOSITORIES)

                    local dir = string.format('%s%s', _MSF.OptionalDirectory, Name)

                    ROUTINES.os.rmdir(dir)

                    print(string.format('%s was removed.', Name))
                else
                    print('Module does not exist.')
                end
            else
                print('Nothing to remove.')
            end
        elseif soft == 'list' then
            local usage = function()
                print('Usage: list')
                print('\t[-i]\tList installed modules.')
                print('\t[-a]\tList available modules.')
            end

            local list = function(table)
                local size = ROUTINES.util.size(table)
                local i = 1

                for k, _ in pairs(table) do
                    io.write(k)

                    if i ~= size then
                        io.write(', ')
                    end

                    i = i + 1
                end
            end

            if not arg[2] then usage() return end

            local flag = arg[2]

            if flag == '-i' then
                if REPOSITORIES then
                    list(REPOSITORIES)
                else
                    print('No modules installed.')
                end
            elseif flag == '-a' then
                if _REPOSITORIES then
                    list(_REPOSITORIES)
                else
                    print('Could not fetch module from GitHub.')
                end
            else
                usage()
            end
        elseif soft == 'freeze' then
            local Freeze = require 'Freeze'
            local Destination = arg[2]

            ROUTINES.file.write(Destination, 'MSF.lua', Freeze.string)
        else
            print('Usage: MSF Soft Mode\n')
            print('\tadd\tAdd a module to MSF.\n')
            print('\tupdate\tUpdate a modules(s) in MSF.\n')
            print('\tremove\tRemove a module in MSF.\n')
            print('\tlist\tList installed and available modules in MSF.\n')
            print('Run "add -help" etc. for more instructions.')
        end
    end
end
