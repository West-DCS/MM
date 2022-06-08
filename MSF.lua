---@author West#9009
---@description Mission Scripting Framework. Initialization functions.
---@created 16MAY22

do
local Directory = lfs.writedir() .. [[Scripts\MSF\]]
local UserDirectory = Directory .. [[Modules\User\]]

-- Load MSF Modules
dofile(Directory .. 'Modules.lua')

for file in lfs.dir(UserDirectory) do
    if ROUTINES.file.isFile(file) then
        if not file == '.' and not file == '..' then
            BASE:Log('info', 'Loading: %s', file)
            dofile(file)
        end
    end
end

-- Log certifies that at least all modules loaded.
BASE:Log('info', '%s initialization finished.', 'MSF')

end
