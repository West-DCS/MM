-- Copy this into a new command to make a custom lua file with only the modules you want.

local Options = {
    -- Name option, set self.Name
    n = {
        fun = function(self, Param) self.Name = Param end,
        desc = 'Optional File Name.',
        param = 'Name'
    },
    -- Remote flag option, also compile a static file that downloads code from GitHub at mission runtime instead.
    -- Useful for production code.
    r = {
       fun = function(self) self.Remote = true end,
       desc = 'Remote Flag. Generate static file as well that downloads code from GitHub at mission runtime instead.'
    },
    -- Append a version number. You can set a custom version or it will pull from config file.
    v = {
        fun = function(self, Param) self.Version = Param or CONFIG.Version or '' end,
        desc = 'Append a version number or string.',
        param = 'Version'
    }
}

-- Instantiate a new COMMAND object.
local Freeze = COMMAND:New('freeze', 'Compile all code into one lua file.', Options)

if not Freeze then return end
if not Freeze.Version then Freeze.Version = '' end
if not Freeze.Name then Freeze.Name = CONFIG.ProjectName end


-- Init Modules in a set directory recursively.
function Freeze:InitModuleDir(DirPath)
    local Init = _MM:TryLoadStringOrFile({DirPath .. 'Init.lua'}, false,
            string.format('No Init.lua in %s', DirPath), true)

    -- If no Init file, then do not load the modules. Priority is unknown.
    if not Init then return end

    for _, Directory in ipairs(Init) do
        self:InitModules(DirPath .. Directory)
    end
end

-- Init Modules in a set directory non-recursively.
function Freeze:InitModules(Directory)
    local Init = _MM:TryLoadStringOrFile({Directory .. '\\Init.lua'}, false,
            string.format('No Init.lua in %s', Directory), true)

    -- If no Init file, then do not load the modules. Priority is unknown.
    if not Init then print('no init') return end

    for _, File in ipairs(Init) do
        local FilePath = Directory .. [[\]] .. File

        local Contents = ROUTINES.file.read(FilePath, '')

        self.File = self.File .. Contents .. '\n'
    end
end

function Freeze:_Remote()
    return string.format([[
    os.execute("curl -s -H " .. '"Accept:application/vnd.github.v3.raw" ' ..
        "https://api.github.com/repos/%s/%s/contents/%s > temp.lua")
    dofile('temp.lua')
    os.remove('temp.lua')
    ]], CONFIG.Remote.User, CONFIG.Remote.Repo, CONFIG.Remote.Path)
end

function Freeze:Execute()
    self.File = ''

    -- Append Community Modules
    self:InitModuleDir(_MM.CommunityDirectory)

    -- Append User Modules
    self:InitModuleDir(_MM.UserDirectory)

    local Name = string.format('%s%s', self.Name, self.Version)

    ROUTINES.file.write(_MM.BuildsDirectory, Name .. '.lua', self.File)

    if self.Remote then
        ROUTINES.file.write(_MM.BuildsDirectory, Name .. 'Remote.lua', self:_Remote())
    end
end

return Freeze
