---@author West#9009
---@description Mission Scripting Framework. Initialization functions.
---@created 16MAY22

-- Load MSF Modules
dofile(lfs.writedir() .. '/Scripts/MSF/Modules.lua')

-- Log certifies that at least all modules loaded.
BASE:Log('info', '%s initialization finished.', 'MSF')
