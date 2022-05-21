-- Required Modules, do not touch. Order is important.
dofile(lfs.writedir() .. '/Scripts/MSF/Modules/Required/Enums.lua')
dofile(lfs.writedir() .. '/Scripts/MSF/Modules/Required/Routines.lua')
dofile(lfs.writedir() .. '/Scripts/MSF/Modules/Required/Base.lua')
dofile(lfs.writedir() .. '/Scripts/MSF/Modules/Required/Events.lua')

-- Instantiates event dispatcher here in case optional modules handle events.
__EVENTS = EVENTS:New()

-- Optional and User Modules, do touch. '--' To comment out and prevent running.
dofile(lfs.writedir() .. '/Scripts/MSF/Modules/Optional/Test.lua')
