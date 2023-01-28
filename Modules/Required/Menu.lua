---@author West#9009
---@description Menu and Menu command functions.
---@created 15JUN22

---@type BASE
MENU = {
    ClassName = 'MENU',
    Commands = {},
    SubMenus = {}
}

--- Instantiate a new MENU object.
---@param Name string The name of the menu.
---@return self
function MENU:New(Name)
    if not Name then return end

    local self = BASE:Inherit(self, BASE:New())

    self.Name = Name

    return self
end

--- Add a SubMenu by passing another Menu object.
---@param Menu table The Menu object to add as a SubMenu.
---@return self
function MENU:AddSubMenu(Menu)
    if not Menu.GetClassName then return end
    if not Menu:GetClassName() == 'MENU' then return end

    self.SubMenus[Menu] = Menu

    return self
end

--- Add a command to the menu.
---@param Name string The name of the command to be executed.
---@param Callback function The function to be executed.
---@return self
function MENU:AddCommand(Name, Callback, ...)
    if not type(Name) == 'string' then return end
    if not type(Callback) == 'function' then return end

    self.Commands[Callback] = {Name = Name, Callback = Callback, Args = ... or {}}

    return self
end

--- Internal function to add the submenus and commands recursively from the root Menu object.
---@param Who table Who args.
---@return self
function MENU:_Add(Who)
    local AddMenu = {}

    AddMenu.Group = function() return missionCommands.addSubMenuForGroup(Who.ID, self.Name, Who.Root) end
    AddMenu.Coalition = function() return missionCommands
            .addSubMenuForCoalition(Who.CoalitionEnum, self.Name, Who.Root) end
    AddMenu.All = function() return missionCommands.addSubMenu(self.Name, Who.Root) end

    local AddCommand = {}

    AddCommand.Group = function(self, Command) return missionCommands
                    .addCommandForGroup(Who.ID, Command.Name, self.Root, Command.Callback, Command.Args) end
    AddCommand.Coalition = function(self, Command) return missionCommands
            .addCommandForCoalition(Who.CoalitionEnum, Command.Name, self.Root, Command.Callback, Command.Args) end
    AddCommand.All = function(self, Command) return missionCommands
            .addCommand(Command.Name, self.Root, Command.Callback, Command.Args) end

    self.Root = AddMenu[Who.Who](self)
    Who.Root = self.Root

    for _, Menu in pairs(self.SubMenus) do
        Menu:_Add(Who)
    end

    for _, Command in pairs(self.Commands) do
        self.Commands[Command.Callback].Ref = AddCommand[Who.Who](self, Command)
    end

    return self
end

--- Internal function to remove items from Menu from a certain point
---@param Who table Who args.
---@return self
function MENU:_Remove(Who)
    if not Who.Root then return end

    local Remove = {}

    Remove.Group = function() return missionCommands.removeItemForGroup(Who.ID, Who.Root) end
    Remove.Coalition = function() return missionCommands
            .removeItemForCoalition(Who.CoalitionEnum, Who.Root) end
    Remove.All = function() return missionCommands.removeItem(Who.Root) end

    Remove[Who.Who]()

    return self
end

--- Add the Menu to a group.
---@param Group table The Group object wrapper to add.
---@return self
function MENU:AddToGroup(Group)
    if not Group.GetClassName then return end
    if not Group:GetClassName() == 'GROUP' then return end

    local Who = {}
    Who.ID = Group:GetID()
    Who.Who = 'Group'

    self:_Add(Who)

    return self
end

--- Add a menu to an entire Coalition.
---@param CoalitionEnum number The Coalition to add.
---@return self
function MENU:AddToCoalition(CoalitionEnum)
    local Who = {}

    Who.CoalitionEnum = CoalitionEnum
    Who.Who = 'Coalition'

    self:_Add(Who)

    return self
end

--- Add a menu to everyone.
---@return self
function MENU:AddToAll()
    local Who = {}

    Who.Who = 'All'

    self:_Add(Who)

    return self
end

--- Remove a menu from a group.
---@param MenuOrFunction table|function The menu or function to remove.
---@param Group table The Group wrapper to remove.
---@return self
function MENU:RemoveFromGroup(MenuOrFunction, Group)
    if not Group.GetClassName then return end
    if not Group:GetClassName() == 'GROUP' then return end

    local Who = {}

    Who.Who = 'Group'
    Who.ID = Group:GetID()
    Who.Root = self.SubMenus[MenuOrFunction].Root or self.Commands[MenuOrFunction].Ref

    self:_Remove(Who)

    return self
end

--- Remove a menu from a coalition.
---@param MenuOrFunction table|function The menu or function to remove.
---@param CoalitionEnum number The coalition to remove.
---@return self
function MENU:RemoveFromCoalition(MenuOrFunction, CoalitionEnum)
    local Who = {}

    Who.Who = 'Coalition'
    Who.CoalitionEnum = CoalitionEnum
    Who.Root = self.Commands[MenuOrFunction].Ref

    self:_Remove(Who)

    return self
end

--- Remove a menu or function from everyone.
---@param MenuOrFunction table|function The menu or function to remove.
---@return self
function MENU:RemoveFromAll(MenuOrFunction)
    local Who = {}

    Who.Who = 'All'
    Who.Root = self.Commands[MenuOrFunction].Ref

    self:_Remove(Who)

    return self
end
