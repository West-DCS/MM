---@author West#9009
---@description Mission Scripting Framework. Initialization functions.
---@created 16MAY22

-- Global MSF variable storing core framework functions. Use routines instead of these unless you know what you are
-- doing.
_MSF = {}

-- Initialization from Command-Line
function _MSF:Init()
    -- LFS for file i/o. DCS already has LFS installed. Required for _MSF:SetDirectories().
    lfs = require 'lfs'

    _MSF:SetDirectories()

    -- Error booleans if missing Config.lua, Routines file, or Command file.
    local NoConfig, NoRoutines, NoCommands

    -- User Config File
    _, NoConfig = _MSF:TryLoadStringOrFile({ _MSF.ConfigDirectory .. 'Config.lua' }, false,
            'Missing Config.lua file.\nHint: Rename .Config.lua to Config.lua\n')
    -- Routines file holding common-use functions.
    _, NoRoutines = _MSF:TryLoadStringOrFile({ _MSF.RequiredDirectory .. 'Routines.lua' }, false,
            'Missing Routines File.\n', true)
    -- User Installed repositories. Needed to know for some command-line functions. This is okay to be missing.
    -- User might not have installed anything.
    _, NoCommands = _MSF:TryLoadStringOrFile({ _MSF.Directory .. 'Command.lua' }, false,
            'Missing Command File.\n', true)
    _MSF:TryLoadStringOrFile({ _MSF.ConfigDirectory .. 'REPOSITORIES' }, true)

    if NoConfig or NoRoutines or NoCommands then return end

    -- Error boolean for Repository of MSF modules on GitHub
    local NoRemote

    _, NoRemote = _MSF:TryLoadStringOrFile(ROUTINES.git.raw(
            CONFIG.Repository.User, CONFIG.Repository.Repo, CONFIG.Repository.Path),
            false,
            'An Error Occurred Fetching the Repository From GitHub.\n' ..
            'Hint: You have reached the max amount of requests to GitHub API (60); or,\n' ..
            'you have incorrectly configured the repository in you Config.lua.\n')

    if NoRemote then return end

    -- Generate a list of available commands inside of the Commands Directory.
    local Commands = ROUTINES.file.GetFilesInDir(_MSF.CommandsDirectory)

    -- Command to search and a boolean if an error occurs initializing a command.
    local Command, NoCommand

    -- Test if no arguments provided to MSF, if so, then automatically execute a usage.
    if not arg[1] then
        Command, NoCommand = _MSF:TryLoadStringOrFile({_MSF.CommandsDirectory .. 'Help.lua'}, false,
                'Error in Command.\n', true)

        if NoCommand then return end

        Command:Execute()
    -- Test if the argument provided is a valid command located in commands directory.
    elseif Commands[ROUTINES.string.UpperFirstChar(arg[1]) .. '.lua'] then
        Command, NoCommand= _MSF:TryLoadStringOrFile(
                { Commands[ROUTINES.string.UpperFirstChar(arg[1]) .. '.lua'] }, false,
                'Error in Command.\n', true)

        if NoCommand then return end

        Command:Execute()
    else
        print(string.format("MSF: '%s' is not a valid MSF command. See 'MSF help'.\n", arg[1]))
    end

    return
end

function _MSF:InitDCS()
    _MSF:SetDirectories()

    -- Add LuaSocket which is not included by DCS package.path by default.
    package.path  = package.path .. ';.\\LuaSocket\\?.lua' .. string.format(';%s?.lua', _MSF.Directory)


    _MSF:TryLoadStringOrFile({_MSF.Directory .. 'Modules.lua'}, false,
            'Missing Modules File.', true)

    --TODO Finish optional and user modules.
    ---- Load Optional Modules
    --if REPOSITORIES then
    --    for Module, _ in pairs(REPOSITORIES) do
    --        local Info = dofile(string.format([[%s%s\Info.lua]], _MSF.OptionalDirectory, Module))
    --
    --
    --        BASE:L(Info)
    --        --_MSF:Load(string.format([[%s\Module.lua]], Module), 'Optional')
    --    end
    --end

    ---- Load User Modules (non-recursively, unordered)
    --for file in lfs.dir(_MSF.UserDirectory) do
    --    if ROUTINES.file.isFile(_MSF.UserDirectory .. file) then
    --        BASE:Info('Loading: %s', file)
    --        _MSF:Load(file)
    --    end
    --end

    -- Log certifies that at least all modules loaded.
    BASE:Info('%s initialization finished.', CONFIG.ProjectName)
end

-- Function to determine the working directory of MSF. LFS changes based on whether DCS is running.
function _MSF:SetDirectories()
    if env then
        _MSF.Directory = lfs.writedir() .. string.format([[Scripts\%s\]], CONFIG.ProjectName)
    else
        _MSF.Directory = lfs.currentdir() .. [[\]]
    end

    _MSF.ModulesDirectory = _MSF.Directory .. [[Modules\]]
    _MSF.UserDirectory = _MSF.ModulesDirectory .. [[User\]]
    _MSF.OptionalDirectory = _MSF.ModulesDirectory .. [[Optional\]]
    _MSF.RequiredDirectory = _MSF.ModulesDirectory .. [[Required\]]
    _MSF.ObjectsDirectory = _MSF.RequiredDirectory .. [[Objects\]]
    _MSF.ConfigDirectory = _MSF.Directory .. [[Config\]]
    _MSF.CommandsDirectory = _MSF.ModulesDirectory .. [[Commands\]]
    _MSF.BuildsDirectory = _MSF.Directory .. [[Builds\]]

    return
end

-- Function to safely add Globals without collisions. Collisions can happen with Moose installed.
-- Only needed in dev and DCS environment.
-- The goal of this function is too allow MSF modules even when Moose is installed.
function _MSF:AddGlobalFromFile(NameOfVariable, File)
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
-- i.e. _MSF:TryLoadStringOrFile({PathToAFile})

-- Warning: This function will automatically execute files and strings.
function _MSF:TryLoadStringOrFile(StringOrFile, Silent, ErrorMessage, ThrowError)
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

-- Test if DCS is in globals to determine if DCS is currently active, if so, init with MSF DCS modules.
-- If not, MSF inits all command-line functions.
if env then
    _MSF:InitDCS()
else
    _MSF:Init()
end
