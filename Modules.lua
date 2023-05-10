-- Required Modules, do not touch. Order is important.
--TODO Fix REPOSITORIES missing
--_MSF:Load('REPOSITORIES', 'Config')
_MSF:AddGlobalFromFile('BASE', _MSF.RequiredDirectory .. 'Base.lua')
_MSF:AddGlobalFromFile('ENUMS', _MSF.RequiredDirectory .. 'Enums.lua')
_MSF:AddGlobalFromFile('ROUTINES', _MSF.RequiredDirectory .. 'Routines.lua')
_MSF:AddGlobalFromFile('EVENTS', _MSF.RequiredDirectory .. 'Events.lua')
_MSF:AddGlobalFromFile('ZONE', _MSF.RequiredDirectory .. 'Zone.lua')
_MSF:AddGlobalFromFile('DATABASE', _MSF.RequiredDirectory .. 'Database.lua')
_MSF:AddGlobalFromFile('SPAWN', _MSF.RequiredDirectory .. 'Spawn.lua')
_MSF:AddGlobalFromFile('SET', _MSF.RequiredDirectory .. 'Set.lua')
_MSF:AddGlobalFromFile('MENU', _MSF.RequiredDirectory .. 'Menu.lua')
_MSF:AddGlobalFromFile('MESSAGE', _MSF.RequiredDirectory .. 'Message.lua')
_MSF:AddGlobalFromFile('NET', _MSF.RequiredDirectory .. 'Net.lua')
_MSF:AddGlobalFromFile('SERVER', _MSF.RequiredDirectory .. 'Server.lua')

-- Object Classes
_MSF:AddGlobalFromFile('OBJECT', _MSF.ObjectsDirectory .. 'Object.lua')
_MSF:AddGlobalFromFile('UNIT', _MSF.ObjectsDirectory .. 'Unit.lua')
_MSF:AddGlobalFromFile('GROUP', _MSF.ObjectsDirectory .. 'Group.lua')
_MSF:AddGlobalFromFile('STATIC', _MSF.ObjectsDirectory .. 'Static.lua')
_MSF:AddGlobalFromFile('AIRBASE', _MSF.ObjectsDirectory .. 'Airbase.lua')

-- Instantiates required Classes.
__EVENTS = EVENTS:New()
__DATABASE = DATABASE:New()
