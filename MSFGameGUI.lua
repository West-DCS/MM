do
    local _NMSF = {}

    _NMSF.Directory = lfs.writedir() .. [[Scripts\$\]]

    _NMSF.ModulesDirectory = _NMSF.Directory .. [[Modules\]]
    _NMSF.RequiredDirectory = _NMSF.ModulesDirectory .. [[Required\]]
    _NMSF.UserDirectory = _NMSF.ModulesDirectory .. [[User\]]
    _NMSF.UserHooksDirectory = _NMSF.UserDirectory .. [[Hooks\]]
    _NMSF.ConfigDirectory = _NMSF.Directory .. [[Config\]]
    _NMSF.HooksDirectory = _NMSF.ModulesDirectory .. [[Hooks\]]

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

    NET:Log('#GameGUI Initialized.')
end
