# Welcome to West's MM (Module Manager) for DCS!
MM is a collaborative module manager for DCS, hence it's name. MM will setup a project structure for you to use in your
DCS projects. MM will dynamically load your modules during development with the use of two triggers. For production, you
can generate a static file containing all code, or a static file that remotely loads code from GitHub at runtime. All of
this is accomplished through a suite of command-line development tools.

# Requirements

1. [Git](https://git-scm.com/downloads), For command-line functions.
2. Curl, This should be included in your window's installation if you are using Windows 10 or 11. If not, you can get it
from [here](https://curl.se/windows/). Make sure to add to your path.

# Installation

## Create a Fork (Highly Recommended)
I recommend creating a fork of MM, so you can track your user script files. If this is your own organization's
repository, skip this step.

To do this:

1. On the repository page on GitHub, click the fork button on the top right.
2. Adjust owner as necessary and name the repository whatever you want.
3. If you want, change the description and unselect `Copy the main branch only` if you want to use newer features.
4. Click `Create Fork`.


## Clone Your Repository (Mandatory)
1. If you are unfamiliar with Git, I recommend learning basics before continuing to use MM.
2. You can use command-line or download the code directly from GitHub.
3. Clone the repository into any directory you like.


## Lua 5.1.5 64 bit (Highly Recommended)
Lua 5.1.5 is included and is needed to run MM from the command-line to make use of it's features.
This is the same version that DCS uses, but in theory you could use a newer version. Simply add to your path, the
location of the Lua folder included with this installation.

1. Go to your Environment Variable settings and add `[PathToYourRepository]\Lua` to `Path`

   ![Path example](https://gcdnb.pbrd.co/images/G87jKoZpGUcF.png?o=1)

**You only need to do this once!**


## Sym-linking (Highly Recommended)
Source control is made easier with sym-linking. Files will automatically be linked to your DCS Scripts folder and
tracked with git. The mission initialization script (`MM.lua`) will dynamically add your scripts for you. You can 
instead work out of your script's folder should you wish.

1. Download and install [Link Shell Extension](https://schinagl.priv.at/nt/hardlinkshellext/linkshellextension.html)
2. Restart explorer if necessary.
3. Right-click your repository directory and select *Pick Link Source*
4. Navigate to `?:\Users\[username]\Saved Games\DCS.[version]\Scripts`
5. Right-click and select *Drop As..* > *Symbolic Link*
6. Rename the dropped link directory as anything your would like, preferably the same name as your repository.


## Adding Appropriate Triggers to Mission (Mandatory)
**The order of triggers is very important!**
Note: You cannot use the initialization script function for this. Make sure to replace `[YourRepository]` with the
correct path.

1. Go to triggers in ME, and add a mission start trigger called `Load Config`
2. Add a Do-Script action with the following text: `dofile(lfs.writedir() .. [[Scripts\[YourRepository]\Config\Config.lua]])`
3. Repeat and add another mission start trigger called `Load MM`.
4. Add a Do-Script action with the following text: `dofile(lfs.writedir() .. [[Scripts\[YourRepository]\MM.lua]])`

Your mission will initialize MM and all of your user scripts dynamically, meaning you can change code without having to
add your script to the mission again.


## DCS Sanitation (Mandatory)
To execute code on the mission, `MissionScripting.lua` must not be sanitized. **You must be careful when downloading
missions from other users to prevent unwanted code execution**.

1. Navigate to `[DCS installation]\Scripts\MissionScripting.lua`
2. Adjust the file to no longer sanitize by adding comments. This is necessary to allow MM to operate the File System.

```lua
do
 --sanitizeModule('os')
 --sanitizeModule('io')
 --sanitizeModule('lfs')
 --require = nil
 --loadlib = nil
end
```


## Set Config Options (Mandatory)
MM needs to know a couple of things. Inside your project directory, there is a `Config` directory. Inside is 
`.Config.lua`. The defaults should work fine except for the Project Name which you must change.

1. Copy the file into a new file called `Config.lua` in the same directory.
2. Follow all the instructions within.
3. If you want to, you can delete the `.gitignore` file to add your `Config.lua` back to tracking. Add whatever you want
into your config.


## .env (Optional)
You can add a .env to manage your secrets inside of the Config directory. You may need to provide a GitHub PAT to 
increase your API limit with some of the command-line functions. eg. GITHUBPAT='[YourToken]'

# Command-Line Functions

## Modules From Other Developers
This is the whole reason this framework exists. Instead of including every Module into the framework, you can pick and
choose what you want. For this to work, you must have added lua to your path. MM.lua can be executed from the command
line and has a number of useful functions. All commands can be executed from your project directory.

To install a module:
1. Run: `MM list -a` to list the available repositories.
2. Run: `MM install moose` to add the MOOSE module to your project.

To update a module:
1. Run: `MM update -i moose` or `MM update -a` to update all modules in the project.

To remove a module:
1. Run: `MM remove moose`


## Basic Debugging
MM includes a simple listener that listens to the dcs.log file. To use:

1. Run: `MM listen`
![Listener](https://pasteboard.co/zq5LuV3Caem2.png)

## Other Command-Line Functions

1. Run: `MM help` to see other things you can do.


# Your First Module
The only folder you need to be concerned about are `Modules\User`.
MM dynamically and statically loads modules in this order: Core -> Community -> User.
In each of these module directories there must be an `Init.lua` file. This file dictates in which order modules are
loaded. MM includes an example of how this should be done. The Community modules are automatically initialized for you.

Example:

`Modules\User\Init.lua`

```lua
do
   local Init = {
      'src', -- Load the src directory
      'test1' -- Then load the test1 directory
   }
   
   return Init
end
```

Inside each directory you must include another Init.lua file to specify which files should be loaded by MM.

Example:

`Modules\User\src\Init.lua`

```lua
do
   local Init = {
      'Test.lua' -- Load a file called Test.lua. Must be a relative path if you have more nested directories.
   }
   
   return Init
end
```

MM will now load everything in the correct order! Because MM dynamically loads modules, anything added by MM into 
Community will be accessible to `Test.lua`.

# Generating a Static Lua File 
During development it is useful to dynamically load modules. Your server should probably not do this because this would
require you to set-up MM. Your server should be as simple as possible and your production .miz file should statically 
load MM with one mission trigger. You have to options with MM: you can generate a lua file that contains all your code, 
or you can generate a lua file that loads the code from your repository. To do this we will use `freeze`.

Generate one file with entire code:
1. Run `MM freeze`

Generate one file that downloads code from GitHub at runtime:
1. Run `MM freeze -r` 

This is particularly interesting because you can easily share you missions with custom code with
little to no set-up from end-user.

Modify your .miz file in the ME to only include the lua file generated in the `Builds` directory:
1. Go to triggers in ME, and add a mission start trigger called `Load MM` (or whatever you want).
2. Add a Do Script File action.
3. Open the file generated in `Builds`. Only use the remote file or static file.


# Creating Custom Commands
Creating your own commands are very easy. 

1. Create a new file with the name of the command in `Modules\Core\Commands`

Lets look at the List.lua command as an example.

```lua
-- Define your options. Options are passed like "MM list -a"
-- This is completly optional, you can manually get the arguments using "arg" global.
local Options = {
    -- Flag to list installed modules.
    i = {
        fun = function(self) self.Mode = 'i' end,
        desc = 'Update all modules.'
    },
    -- Flag to list all modules.
    a = {
        fun = function(self)
            self.Mode = 'a'
        end,
        desc = 'Update an individual module.'
    },
    -- You can store parameters supplied by arguments in the following way. They will
    -- be accessible after instantiation if the user supplies them.
    x = {
       fun = function(self, param) self.Example = param  end,
       desc = 'Example description',
       param = 'Example'
    }
}

-- Instantiate a new COMMAND
-- The first argument is the name, the second the description of the command,
-- and the third is the Options you defined earlier.
local List = COMMAND:New('list', 'List installed or available MM modules.', Options)

-- You can create any function you want.
function List:_List(Table)
    for Name, URL in pairs(Table) do
        self:Out('%s <%s>', Name, URL)
    end
end

-- This function automatically gets executed by MM if user runs the command.
function List:Execute()
    if not arg[2] then self:Help() return end

    if self.Mode == 'i' then
        if not REPOSITORIES then self:Out('No modules installed.') return end

        self:_List(REPOSITORIES)
    elseif self.Mode == 'a' then
        self:_List(_REPOSITORIES)
    end
end

return List
```


# Questions?
Join our [Discord](https://www.discord.gg/invite/nAfcePemaa), or DM West#9009.


# Attributions

1. [Lua 5.1.5](https://www.lua.org/)
2. [LuaFileSystem (LFS)](https://github.com/lunarmodules/luafilesystem)
