test('Fails'):expect(function() return 1 end):toBe(2)
test('Passes'):expect(function() return 1 end):toBe(1)