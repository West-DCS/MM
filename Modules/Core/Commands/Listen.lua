-- Instantiate a new COMMAND object.
local Listen = COMMAND:New('listen', 'Listen to dcs.log.', nil)

function Listen:Execute()
    -- Open the file for reading
    local LogFilePath = CONFIG.SavedGames .. 'Logs\\dcs.log'

    -- Protect against interrupts.
    pcall(os.execute, string.format('py %s\\Listen.py "%s"', _MM.CommandsDirectory, LogFilePath))
end

return Listen
