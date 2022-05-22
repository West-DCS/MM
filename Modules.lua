-- Required Modules, do not touch. Order is important.
dofile(lfs.writedir() .. '/Scripts/MSF/Modules/Required/Enums.lua')
dofile(lfs.writedir() .. '/Scripts/MSF/Modules/Required/Routines.lua')
dofile(lfs.writedir() .. '/Scripts/MSF/Modules/Required/Base.lua')
dofile(lfs.writedir() .. '/Scripts/MSF/Modules/Required/Events.lua')
dofile(lfs.writedir() .. '/Scripts/MSF/Modules/Required/Database.lua')

-- Wrapper Classes
dofile(lfs.writedir() .. '/Scripts/MSF/Modules/Required/Object.lua')
dofile(lfs.writedir() .. '/Scripts/MSF/Modules/Required/Unit.lua')
dofile(lfs.writedir() .. '/Scripts/MSF/Modules/Required/Group.lua')

-- Instantiates event dispatcher here in case optional modules handle events.
__EVENTS = EVENTS:New()
__DATABASE = DATABASE:New()

-- Optional and User Modules, do touch. '--' To comment out and prevent running.
dofile(lfs.writedir() .. '/Scripts/MSF/Modules/Optional/Test.lua')
