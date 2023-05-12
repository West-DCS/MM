CONFIG = {
    -- Set the directory of your DCS Saved Games folder. You must include \\ at the end to escape the \
    -- This default may work just fine for your install.
    SavedGames = string.format('C:\\Users\\%s\\Saved Games\\DCS.openbeta\\', os.getenv('USERNAME')),
    -- !IMPORTANT! Set the project name to the same name as your repository folder.
    ProjectName = 'MM',
    -- This is the file where information about repositories is stored on GitHub.
    Repository = {User = 'nicelym', Repo = 'MSF_Repositories', Path = 'REPOSITORIES'},
    -- Remote repository for remote GitHub static Lua file.
    -- Change User to your username, and Repo to your repo.
    Remote = {User = 'nicelym', Repo = 'MM'},
    -- Give priority to MOOSE (in this example), so that it loads before other modules.
    AutoPriority = 'moose'
}

-- Remote Build File location. This should work for you by default.
CONFIG.Remote.Path = string.format('Builds/%s.lua', CONFIG.Remote.Repo)