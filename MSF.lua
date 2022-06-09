---@author West#9009
---@description Mission Scripting Framework. Initialization functions.
---@created 16MAY22

do

_MSF = {}
_MSF.Directory = lfs.writedir() .. [[Scripts\MSF\]]
_MSF.ModulesDirectory = _MSF.Directory .. [[Modules\]]
_MSF.UserDirectory = _MSF.ModulesDirectory .. [[User\]]
_MSF.OptionalDirectory = _MSF.ModulesDirectory .. [[Optional\]]
_MSF.RequiredDirectory = _MSF.ModulesDirectory .. [[Required\]]
_MSF.ObjectsDirectory = _MSF.RequiredDirectory .. [[Objects\]]
_MSF.ConfigDirectory = _MSF.Directory .. [[Config\]]

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
        f()
    end
end

-- Load MSF Modules
dofile(_MSF.Directory .. 'Modules.lua')

-- Load User Modules (non-recursively, unordered)
for file in lfs.dir(_MSF.UserDirectory) do
    if ROUTINES.file.isFile(_MSF.UserDirectory .. file) then
        BASE:Info('Loading: %s', file)
        _MSF:Load(file)
    end
end

-- Log certifies that at least all modules loaded.
BASE:Info('%s initialization finished.', 'MSF')

end
