local Freeze = {}

Freeze.string = 'package.path  = package.path .. ";.\\LuaSocket\\?.lua"\n'

local Files = {
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

-- MSF Modules
for _, File in ipairs(Files) do
    print(File)
    local Contents = ROUTINES.file.read(lfs.currentdir() .. File, '')

    Freeze.string = Freeze.string .. Contents
end

Freeze.string = string.format('%s\n__EVENTS = EVENTS:New()\n__DATABASE = DATABASE:New()\n', Freeze.string)

-- User Files
for File in lfs.dir(_MSF.UserDirectory) do
    if ROUTINES.file.isFile(_MSF.UserDirectory .. File) then

        local Contents = ROUTINES.file.read(_MSF.UserDirectory .. File, '')

        Freeze.string = Freeze.string .. Contents
    end
end

return Freeze
