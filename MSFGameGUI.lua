_NMSF = {}

_NMSF.Directory = lfs.writedir() .. [[Scripts\$\]]

_NMSF.ModulesDirectory = _NMSF.Directory .. [[Modules\]]
_NMSF.RequiredDirectory = _NMSF.ModulesDirectory .. [[Required\]]
_NMSF.UserDirectory = _NMSF.ModulesDirectory .. [[User\]]
_NMSF.UserHooksDirectory = _NMSF.UserDirectory .. [[Hooks\]]
_NMSF.ConfigDirectory = _NMSF.Directory .. [[Config\]]
_NMSF.HooksDirectory = _NMSF.ModulesDirectory .. [[Hooks\]]

_NMSF.load = function()
    dofile(_NMSF.ConfigDirectory .. 'Config.lua')
    dofile(_NMSF.RequiredDirectory .. 'Routines.lua')
    dofile(_NMSF.HooksDirectory .. 'Base.lua')
    dofile(_NMSF.HooksDirectory .. 'Events.lua')
    dofile(_NMSF.RequiredDirectory .. 'Net.lua')

    -- Load User Modules (non-recursively, unordered)
    for file in lfs.dir(_NMSF.UserHooksDirectory) do
        if ROUTINES.file.isFile(_NMSF.UserHooksDirectory .. file) then
            NET:Log('Loading: %s', file)
            dofile(_NMSF.UserHooksDirectory .. file)
        end
    end
end

-- Initial Load
_NMSF.load()

-- Everytime a mission loads, reload all hooks.
__LOADER = BASE:New():HandleEvent('Load', _NMSF.load)

NET:Log('#GameGUI Initialized.')
