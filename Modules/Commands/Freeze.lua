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
    }
}

local Freeze = COMMAND:New('freeze', 'Compile all code into one lua file.', Options)

if not Freeze then return end

-- Top of file package path.
Freeze.String = 'package.path  = package.path .. ";.\\\\LuaSocket\\\\?.lua"\n'

-- Generally, you will always want to include these because of how intertwined each file is. Removing any of these can
-- break the entire framework. The order is important.
Freeze.Include = {
    [[\Config\Config.lua]],
    [[\Modules\Required\Enums.lua]],
    [[\Modules\Required\Routines.lua]],
    [[\Modules\Required\Base.lua]],
    [[\Modules\Required\Events.lua]],
    [[\Modules\Required\Zone.lua]],
    [[\Modules\Required\Database.lua]],
    [[\Modules\Required\Spawn.lua]],
    [[\Modules\Required\Set.lua]],
    [[\Modules\Required\Menu.lua]],
    [[\Modules\Required\Message.lua]],
    [[\Modules\Required\Net.lua]],
    [[\Modules\Required\Server.lua]],
    [[\Modules\Required\Objects\Object.lua]],
    [[\Modules\Required\Objects\Unit.lua]],
    [[\Modules\Required\Objects\Group.lua]],
    [[\Modules\Required\Objects\Static.lua]],
    [[\Modules\Required\Objects\Airbase.lua]]
}

-- Global Variables are instantiated after Include
Freeze.Globals = {
    '__EVENTS = EVENTS:New()',
    '__DATABASE = DATABASE:New()'
}

function Freeze:_GetFiles(Directory)
    local Files = {}

    for File in lfs.dir(Directory) do
        table.insert(Files, File)
    end

    return Files
end

function Freeze:_Append(Table, Directory)
    local Directory = Directory or ''

    for _, File in pairs(Table) do
        local Path = Directory .. File

        if ROUTINES.file.isFile(Path) and Directory ~= '' then
            self:Out(string.format('Compiling: %s', File))

            local Contents = ROUTINES.file.read(Path, '')

            Freeze.String = string.format('%s\n%s', Freeze.String, Contents)
        elseif Directory == '' then
            Freeze.String = string.format('%s\n%s', Freeze.String, File)
        end
    end

    -- Another new-line for pretty formatting.
    Freeze.String = string.format('%s\n', Freeze.String)
end

function Freeze:Execute(Args)
    if not Args[2] then self:Help() return end

    local OutputPath = Args[2]
    if OutputPath == '-help' then self:Help() return end

    self:Out(OutputPath)

    -- Required
    self:_Append(Freeze.Include, _MSF.Directory)
    -- Global Variables
    self:_Append(Freeze.Globals)
    -- User Files
    self:_Append(self:_GetFiles(_MSF.UserDirectory), _MSF.UserDirectory)

    ROUTINES.file.write(OutputPath, 'MSF.lua', Freeze.String)
end

function Freeze:Help()
    self:Out('Usage: freeze <OutputPath>')
end

return Freeze
