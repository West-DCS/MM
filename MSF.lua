---@author West#9009
---@description Mission Scripting Framework. Initialization functions.
---@created 16MAY22

do
    _MSF = {}

    local soft

    if arg then
        soft = arg[1]
    end

    if not soft then
        _MSF.Directory = lfs.writedir() .. [[Scripts\MSF\]]
        _MSF.ModulesDirectory = _MSF.Directory .. [[Modules\]]
        _MSF.UserDirectory = _MSF.ModulesDirectory .. [[User\]]
        _MSF.OptionalDirectory = _MSF.ModulesDirectory .. [[Optional\]]
        _MSF.RequiredDirectory = _MSF.ModulesDirectory .. [[Required\]]
        _MSF.ObjectsDirectory = _MSF.RequiredDirectory .. [[Objects\]]
        _MSF.ConfigDirectory = _MSF.Directory .. [[Config\]]

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

        -- Load User Modules (non-recursively, unordered)
        for file in lfs.dir(_MSF.UserDirectory) do
            if ROUTINES.file.isFile(_MSF.UserDirectory .. file) then
                BASE:Info('Loading: %s', file)
                _MSF:Load(file)
            end
        end

        -- Log certifies that at least all modules loaded.
        BASE:Info('%s initialization finished.', 'MSF')
    else
        _MSF.Directory = io.popen"cd":read'*l' .. [[\]]
        _MSF.ModulesDirectory = _MSF.Directory .. [[Modules\]]
        _MSF.OptionalDirectory = _MSF.ModulesDirectory .. [[Optional\]]
        _MSF.ConfigDirectory = _MSF.Directory .. [[Config\]]

        function _MSF.Load(File)
            local f = loadfile(File)

            if f then
                f()
                return true
            end
        end

        -- Load Routines for external use.
        _MSF.Load(_MSF.ModulesDirectory .. [[Required\Routines.lua]])

        local OutFile = _MSF.Load(_MSF.ConfigDirectory .. 'REPOSITORIES')

        if soft == 'add' then
            local isError = false
            local Name = arg[2]

            if Name then
                local Repository

                if OutFile ~= nil then
                    Repository = REPOSITORIES[Name]
                else
                    REPOSITORIES = {}
                end

                local Argument
                local Destination
                local URL

                if Repository then
                    Destination = _MSF.OptionalDirectory .. Name
                    URL = Repository
                else
                    URL = arg[3]

                    if URL then
                        Destination = _MSF.OptionalDirectory .. Name
                    else
                        isError = true
                        print('This repository is not indexed, you must provide a URL as a third argument.')
                    end
                end

                if not isError then
                    Argument = URL .. [[ ]] .. Destination

                    ROUTINES.os.exec('git clone', Argument)

                    REPOSITORIES[Name] = URL

                    ROUTINES.file.EDSerializeToFile(_MSF.ConfigDirectory, 'REPOSITORIES', REPOSITORIES)
                end
            else
                print('You must provide a repository to add.')
            end
        elseif soft == 'update' then
            if OutFile then
                local method = arg[2]

                -- Update all repositories.
                if method == '-a' then
                    for repo, _ in pairs(REPOSITORIES) do
                        local path = _MSF.OptionalDirectory .. repo

                        ROUTINES.os.exec(string.format('git -C %s pull origin main', path))
                    end
                -- Update an individual repository.
                elseif method == '-i' then
                    local repo = arg[3]

                    if REPOSITORIES[repo] then
                        local path = _MSF.OptionalDirectory .. repo

                        ROUTINES.os.exec(string.format('git -C %s pull origin main', path))
                    else
                        print('Repository not indexed, cannot update.')
                    end
                end
            else
                print('Nothing to update.')
            end
        end
    end
end
