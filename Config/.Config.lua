CONFIG = {
    -- Set the directory of your DCS Saved Games folder. You must include \\ at the end to escape the \
    -- This default may work just fine for your install.
    SavedGames = string.format('C:\\Users\\%s\\Saved Games\\DCS.openbeta\\', os.getenv('USERNAME')),
    -- Set the project name to the same name as your repository folder.
    ProjectName = 'MSF',
    -- This is the file where information about repositories is stored on GitHub.
    Repository = {User = 'nicelym', Repo = 'MSF_Repositories', Path = 'REPOSITORIES'},
    -- Remote repository for remote GitHub static Lua file.
    Remote = {User = 'nicelym', Repo = 'MSF', Path = 'Builds\\{YourBuildFile}.lua'}
}
