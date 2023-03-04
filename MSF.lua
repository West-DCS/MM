---@author West#9009
---@description Mission Scripting Framework. Initialization functions.
---@created 16MAY22

do
    _MSF = {}

    local Command

    if arg then
        lfs = require 'lfs'

        Command = arg[1]

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
    _MSF.CommandsDirectory = _MSF.ModulesDirectory .. [[Commands\]]
    _MSF.BuildsDirectory = _MSF.Directory .. [[Builds\]]

    if not Command then
        package.path  = package.path .. ';.\\LuaSocket\\?.lua' .. string.format(';%s?.lua', _MSF.Directory)

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
            for Module, _ in pairs(REPOSITORIES) do
                local Info = dofile(string.format([[%s%s\Info.lua]], _MSF.OptionalDirectory, Module))


                BASE:L(Info)
                --_MSF:Load(string.format([[%s\Module.lua]], Module), 'Optional')
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
        dofile(_MSF.ConfigDirectory .. 'Config.lua')
        dofile(_MSF.RequiredDirectory .. 'Routines.lua')
        dofile(_MSF.ConfigDirectory .. 'REPOSITORIES')

        loadstring(ROUTINES.git.raw(CONFIG.Repository.User, CONFIG.Repository.Repo, CONFIG.Repository.Path))()

        local FoundCommand = false

        for File in lfs.dir(_MSF.CommandsDirectory) do
            if ROUTINES.file.isFile(_MSF.CommandsDirectory .. File) then
                local Name = string.match(File, '(.*)%.')

                if string.lower(arg[1]) == string.lower(Name) then
                    FoundCommand = true

                    break
                end
            end
        end

        dofile(_MSF.Directory .. 'Command.lua')

        if FoundCommand then
            FoundCommand = require(string.format('Modules\\Commands\\%s', arg[1]))

            -- Command could be boolean if -h, -help, or help was passed as argument.
            if type(FoundCommand) == 'table' then
                FoundCommand:Execute(arg)
            end
        else
            FoundCommand = require 'Modules\\Commands\\Help'
            FoundCommand:Execute()
        end
    end
end
