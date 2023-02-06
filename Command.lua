-- Simple Class to add command line functions to MSF, might do more later with this.
COMMAND = {}

function COMMAND:New()
    return ROUTINES.util.deepCopy(self)
end

function COMMAND:Execute(Args)

end

function COMMAND:Help()

end

function COMMAND:Out(String, ...)
    local Out = string.format(String, ...)

    print(Out)
end
