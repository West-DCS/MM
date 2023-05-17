---@author West#9009
---@description Mission Scripting Framework. Initialization functions.
---@created 16MAY22

-- Global MSF variable storing core framework functions. Use routines instead of these unless you know what you are
-- doing.
_MM = {}

-- Initialization from Command-Line
function _MM:Init()
    -- LFS for file i/o. DCS already has LFS installed. Required for _MM:SetDirectories().
    lfs = require 'lfs'

    _MM:SetDirectories()

    -- Error booleans if missing Config.lua, Routines file, or Command file.
    local NoConfig, NoRoutines, NoCommands

    -- User Config File
    _, NoConfig = _MM:TryLoadStringOrFile({ _MM.ConfigDirectory .. 'Config.lua' }, false,
            'Missing Config.lua file.\nHint: Rename .Config.lua to Config.lua\n')

    if NoConfig then return end

    -- User Secrets
    _MM:TryLoadStringOrFile({ _MM.ConfigDirectory .. '.env' })

    -- User Installed repositories. Needed to know for some command-line functions. This is okay to be missing.
    _MM:TryLoadStringOrFile({ _MM.ConfigDirectory .. 'REPOSITORIES' }, true)

    -- Load MM Core Modules
    _MM:InitModules(_MM.CoreDirectory)

    -- Error boolean for Repository of MSF modules on GitHub
    local NoRemote

    _, NoRemote = _MM:TryLoadStringOrFile(ROUTINES.git.raw(
            CONFIG.Repository.User, CONFIG.Repository.Repo, CONFIG.Repository.Path),
            false,
            'An Error Occurred Fetching the Repository From GitHub.\n' ..
            'Hint: You have reached the default max amount of requests to GitHub API (60); or,\n' ..
            'you have incorrectly configured the repository in you Config.lua.\n\n' ..
            'You can increase your API limit by adding your PAT as GITHUBPAT to an .env file.')

    if NoRemote then return end

    -- Generate a list of available commands inside of the Commands Directory.
    local Commands = ROUTINES.file.GetFilesInDir(_MM.CommandsDirectory)

    -- Command to search and a boolean if an error occurs initializing a command.
    local Command, NoCommand

    -- Test if no arguments provided to MSF, if so, then automatically execute a usage.
    if not arg[1] then
        Command, NoCommand = _MM:TryLoadStringOrFile({_MM.CommandsDirectory .. 'Help.lua'}, false,
                'Error in Command.\n', true)

        if NoCommand then return end

        Command:Execute()
    -- Test if the argument provided is a valid command located in commands directory.
    elseif Commands[ROUTINES.string.UpperFirstChar(arg[1]) .. '.lua'] then
        Command, NoCommand= _MM:TryLoadStringOrFile(
                { Commands[ROUTINES.string.UpperFirstChar(arg[1]) .. '.lua'] }, false,
                'Error in Command.\n', true)

        if NoCommand then return end

        -- If user just want's info on a command, do no execute.
        if arg[2] == string.lower('help') then Command:Help() return end

        Command:Execute()
    else
        print(string.format("MSF: '%s' is not a valid MSF command. See 'MSF help'.\n", arg[1]))
    end

    return
end

function _MM:InitDCS()
    _MM:SetDirectories()

    -- Load Community modules.
    _MM:InitModuleDir(_MM.CommunityDirectory)

    -- Load User modules.
    _MM:InitModuleDir(_MM.UserDirectory)

    -- Log certifies that at least all modules loaded.
    env.info(string.format('%s initialization finished.', CONFIG.ProjectName))
end

-- Function to determine the working directory of MSF. LFS changes based on whether DCS is running.
function _MM:SetDirectories()
    if env then
        _MM.Directory = lfs.writedir() .. string.format([[Scripts\%s\]], CONFIG.ProjectName)
    else
        _MM.Directory = lfs.currentdir() .. [[\]]
    end

    _MM.ModulesDirectory = _MM.Directory .. [[Modules\]]
    _MM.UserDirectory = _MM.ModulesDirectory .. [[User\]]
    _MM.CommunityDirectory = _MM.ModulesDirectory .. [[Community\]]
    _MM.CoreDirectory = _MM.ModulesDirectory .. [[Core\]]
    _MM.ObjectsDirectory = _MM.CoreDirectory .. [[Objects\]]
    _MM.ConfigDirectory = _MM.Directory .. [[Config\]]
    _MM.CommandsDirectory = _MM.CoreDirectory .. [[Commands\]]
    _MM.BuildsDirectory = _MM.Directory .. [[Builds\]]
    _MM.TestDirectory = _MM.ModulesDirectory .. [[Tests\]]

    return
end

-- Function to safely add Globals without collisions. Collisions can happen with Moose installed.
-- Only needed in dev and DCS environment.
-- The goal of this function is too allow MSF modules even when Moose is installed.
function _MM:AddGlobalFromFile(NameOfVariable, File)
    -- Test if proposed variable name exists in global table.
    if rawget(_G, NameOfVariable) ~= nil then
        env.warning(string.format(
                'Collision Alert: %s already exists.\n' ..
                        'You can safely ignore this warning if you are using MOOSE.', NameOfVariable))

        return false

    end

    -- Tries to load a file that adds a global variable, but only if no obvious errors in file.
    -- Errors here will stop program, so no need to return anything.
    self:TryLoadStringOrFile({ File }, false, string.format('Error in %s', File), true)

    -- Returning nil, returning something here is not necessary with globals.
    return
end

-- This function is similar to dofile(), but only throw's an error if ThrowError is true.
-- Files must be passed as a table, otherwise will default to loadstring
-- i.e. _MM:TryLoadStringOrFile({PathToAFile})

-- Warning: This function will automatically execute files and strings.
function _MM:TryLoadStringOrFile(StringOrFile, Silent, ErrorMessage, ThrowError)
    -- f is the function loaded from a file, error is optional return from loadfile if an error occurs.
    local f, Error, LoadFunction

    -- A table indicated that we should treat the string at index 1, as a filepath.
    if type(StringOrFile) == 'table' then
        LoadFunction = loadfile
        StringOrFile = StringOrFile[1]
    -- Just a normal string to evaluate.
    elseif type(StringOrFile) == 'string' then
        LoadFunction = loadstring
    else
        return nil, string.format('Not valid type, you provided type: %s', type(StringOrFile))
    end

    -- If the file should stop code execution if a file is missing or an error occurs.
    if ThrowError then
        -- Assert stops code execution, uses ErrorMessage if provided with trace message.
        f, Error = assert(LoadFunction(StringOrFile), ErrorMessage or nil)
        -- The file won't stop code execution. Error is handled elsewhere.
    else
        f, Error = LoadFunction(StringOrFile)
    end

    -- If the function exists, execute and return the return of the function (maybe nothing).
    if f then return f() end

    -- If the error should be logged to DCS.log in the case of running DCS, or output to command-line.
    if not Silent then
        -- DCS env global variable, error level. Logs the ErrorMessage or by default the error from loadfile.
        if env then
            env.error(ErrorMessage or Error)
        else
            -- Set text to red.
            io.write('\27[31m')

            print(ErrorMessage or Error)

            -- Set text to default color.
            io.write('\27[0m')
        end
    end

    -- If we get to here, there was some error in file or string.
    return f, Error
end

-- Init Modules in a set directory recursively.
function _MM:InitModuleDir(DirPath)
    local Init = _MM:TryLoadStringOrFile({DirPath .. 'Init.lua'}, false,
            string.format('No Init.lua in %s', DirPath))

    -- If no Init file, then do not load the modules. Priority is unknown.
    if not Init then return end

    for _, Directory in ipairs(Init) do
        _MM:InitModules(DirPath .. Directory)
    end
end

-- Init Modules in a set directory non-recursively.
function _MM:InitModules(Directory, IgnoreInit, Hook)
    local Init

    if not IgnoreInit then
        Init = _MM:TryLoadStringOrFile({Directory .. '\\Init.lua'}, false,
                string.format('No Init.lua in %s', Directory))

        -- If no Init file, then do not load the modules. Priority is unknown.
        if not Init then print('no init') return end
    end

    -- If an Init file should be ignored or is not present, get the files that exist in a directory.
    if IgnoreInit then Init = ROUTINES.file.GetFilesInDir(Directory, true, true) end

    for _, File in ipairs(Init) do
        local FilePath = Directory .. [[\]] .. File

        if Hook then
            Hook({
                Dir = Directory,
                File = File
            })
        end

        _MM:TryLoadStringOrFile({FilePath}, false,
                string.format('Error in %s', FilePath), true)
    end
end

-- Test if DCS is in globals to determine if DCS is currently active, if so, init with MSF DCS modules.
-- If not, MSF inits all command-line functions.
if env then
    _MM:InitDCS()
else
    _MM:Init()
end
