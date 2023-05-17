local Test = COMMAND:New('test', 'Run automated tests.')

function Test:Execute()
    print('Running Tests')
    _MM:InitModules(_MM.TestDirectory, true)
end

function Test:Help()
    self:Out('Usage: test\tRun automated tests.')
end

return Test
