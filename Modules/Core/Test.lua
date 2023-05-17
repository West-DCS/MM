TEST = {
    Failed = {},
    Passed = {}
}

function TEST:New()
    return ROUTINES.util.deepCopy(self)
end

function TEST:_SetActiveTestSuite(FileName)
    self.ActiveTestSuite = FileName

    return self
end

function TEST:test(Description)
    self.Description = Description

    return self
end

function TEST:expect(Function, ...)
    self.Result = nil

    if type(Function) == 'function' then
        self.Result = Function(...)
    else
        self.Result = Function
    end

    return self
end

function TEST:toBe(Value)
    if Value ~= self.Result then
        if not self.Failed[self.ActiveTestSuite] then
            self.Failed[self.ActiveTestSuite] = {}
        end

        table.insert(self.Failed[self.ActiveTestSuite], self.Description)
    else

    end
end

TEST:New()

function test(Description)
    return TEST:test(Description)
end
