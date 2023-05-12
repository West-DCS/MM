local Help = COMMAND:New('Help', 'Overview of the program.')

function Help:Execute()
    self:Help()
end

function Help:Help()
    self:Out('Usage: MSF Command-Line\n')
    self:Out('\tadd\tAdd a module to MSF.\n')
    self:Out('\tupdate\tUpdate a module(s) in MSF.\n')
    self:Out('\tremove\tRemove a module in MSF.\n')
    self:Out('\tlist\tList installed and available modules in MSF.\n')
    self:Out('\tfreeze\tCompile all code into one lua file.\n')
    self:Out('Run "add -help" etc. for more instructions.')
end

return Help
