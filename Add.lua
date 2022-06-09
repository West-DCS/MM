---@author West#9009
---@description Add modules from GitHub into your project.
---@created 06JUN22

do

local Repositories = require 'Repositories'

local RepoArgument = arg[1]
local Repository = Repositories[RepoArgument] or RepoArgument
local Destination = io.popen"cd":read'*l' .. [[\Modules\Optional\]] .. RepoArgument
local Argument = Repository .. [[ ]] .. Destination

local exec = function(cmd, args)
    os.execute(string.format('%s %s', cmd, args))
end

exec('git clone', Argument)

end
