---@author West#9009
---@description Mission Scripting Framework. Initialization functions.
---@created 16MAY22

do

local Directory = lfs.writedir() .. [[Scripts\MSF\]]
local UserDirectory = Directory .. [[Modules\User\]]

-- Load MSF Modules
dofile(Directory .. 'Modules.lua')

-- Load User Modules (non-recursively, unordered)
for file in lfs.dir(UserDirectory) do
    if ROUTINES.file.isFile(UserDirectory .. file) then
        BASE:Info('Loading: %s', file)

        local f, err = loadfile(UserDirectory .. file)

        if not f then
            BASE:Error('Error in file: %s', file)
            BASE:Error(err)
        else
            f()
        end
    end
end

-- Log certifies that at least all modules loaded.
BASE:Log('info', '%s initialization finished.', 'MSF')

end
