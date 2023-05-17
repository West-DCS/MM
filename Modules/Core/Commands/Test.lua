local Test = COMMAND:New('test', 'Run automated tests.')

local function LoadHook(Event)
    TEST:_SetActiveTestSuite(Event.File)
end

function Test:LoopResults()

end

function Test:Execute()
    _MM:InitModules(_MM.TestDirectory, true, LoadHook)

    for File, Failures in pairs(TEST.Failed) do
        self:Out(File)
        for _, Failure in ipairs(Failures) do
            self:Out('\t%s', Failure)
        end

    end
end

function Test:Help()
    self:Out('Usage: test\tRun automated tests.')
end

return Test
