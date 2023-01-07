-- Required Modules, do not touch. Order is important.
_MSF:Load('Config.lua', 'Config')
_MSF:Load('REPOSITORIES', 'Config')
_MSF:Load('Enums.lua', 'Required')
_MSF:Load('Routines.lua', 'Required')
_MSF:Load('Base.lua', 'Required')
_MSF:Load('Events.lua', 'Required')
_MSF:Load('Zone.lua', 'Required')
_MSF:Load('Database.lua', 'Required')
_MSF:Load('Spawn.lua', 'Required')
_MSF:Load('Set.lua', 'Required')
_MSF:Load('Menu.lua', 'Required')
_MSF:Load('Message.lua', 'Required')
_MSF:Load('Net.lua', 'Required')

-- Object Classes
_MSF:Load('Object.lua', 'Objects')
_MSF:Load('Unit.lua', 'Objects')
_MSF:Load('Group.lua', 'Objects')
_MSF:Load('Static.lua', 'Objects')
_MSF:Load('Airbase.lua', 'Objects')

-- Instantiates required Classes.
NET = NET:_New()
__EVENTS = EVENTS:New()
__DATABASE = DATABASE:New()
