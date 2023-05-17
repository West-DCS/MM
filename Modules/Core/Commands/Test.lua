local Test = COMMAND:New('test', 'Run automated tests.')

local function LoadHook(Event)
    TEST:_SetActiveTestSuite(Event.File)
end

function Test:LoopResults()

end

function Test:Execute()
    print('Running Tests')
    _MM:InitModules(_MM.TestDirectory, true)
end

function Test:Help()
    self:Out('Usage: test\tRun automated tests.')
end

return Test
