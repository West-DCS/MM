---@author West#9009
---@description Functions for dynamically adding groups into mission.
---@created 22MAY22

---@type BASE
---@class SPAWN
SPAWN = {
    ClassName = 'SPAWN',
    Offset = {x = 0, z = 10},
    UnitIterator = 1,
}

--- Create a new ground unit SPAWN class from a type name.
---@param TypeUnit string Optional The type name of the unit to spawn.
---@param Country number Optional The country ID of the unit to spawn.
---@param Name string Optional The name of the unit to spawn.
---@param Skill string Optional The skill of the unit to spawn. {'Excellent', 'High', 'Good', 'Average', 'Random'}
---@param Heading number Optional The heading to spawn in radians.
---@param CanDrive boolean Optional Can the unit be player driven.
---@param Args table Optional Hard set values. eg. {x = number, y = number}
---@return SPAWN Returns self.
function SPAWN:NewGroundFromType(TypeUnit, Country, Name, Skill, Heading, CanDrive, Args)
    local self = BASE:Inherit(self, BASE:New())

    self.Name = Name or 'Group#' .. __DATABASE:_Iterate()
    self.Static = false
    self.Category = Group.Category.GROUND
    self.TypeUnit = TypeUnit or 'Leopard-2'
    self.Country = Country or country.id.USA
    self.Skill = Skill or 'Random'
    self.Heading = Heading or 0
    self.CanDrive = CanDrive or true
    self.Args = Args or {}
    self.Units = {}

    self:AddUnit()

    __DATABASE:_Iterate()
    return self
end

--- Create a new static object SPAWN class from a type name.
---@param TypeUnit string Optional The type name of the unit to spawn.
---@param Category string Optional The category of the static object. eg. 'Heliports'.
---@param Country number Optional The country ID of the unit to spawn.
---@param Heading number Optional The heading to spawn in radians.
---@param Livery string Optional The livery of an aircraft static object.
---@param ShapeFile string Optional The shapefile as required by some statics. eg. 'invisiblefarp' for Invis. FARPs
---@param FARP boolean Optional Is the static a FARP.
---@param Callsign number Optional The callsign of the FARP.
---@param Freq number Optional The frequency of the FARP.
---@param Mod number Optional The modulation of the FARP.
---@return SPAWN Returns self.
function SPAWN:NewStaticFromType(TypeUnit, Category, Country, Heading, Livery, ShapeFile, FARP, Callsign, Freq, Mod)
    local self = BASE:Inherit(self, BASE:New())

    self.Name = 'Static#' .. __DATABASE:_Iterate()

    self.Static = true
    self.Category = Category or 'Structures'
    self.TypeUnit = TypeUnit or 'Hangar B'
    self.Country = Country or country.id.USA
    self.Heading = Heading or 0

    if Livery then
        self.Livery = Livery
    end

    if ShapeFile then
        self.ShapeFile = ShapeFile
    end

    if FARP then
        self.FARP = FARP
        self.Callsign = Callsign or 1
        self.Freq = Freq or 127.5
        self.Mod = Mod or 0
        self.Name = 'FARP#' .. __DATABASE._GroupIterator
    end

    __DATABASE:_Iterate()
    return self
end

--- Add units before spawning to the instantiated SPAWN class. Works only for non-static objects.
---@param TypeUnit string Optional The type name of the unit to spawn.
---@param Skill string Optional The skill of the unit to spawn. {'Excellent', 'High', 'Good', 'Average', 'Random'}
---@param Heading number Optional The heading to spawn in radians.
---@param CanDrive boolean Optional Can the unit be player driven.
---@param Args table Optional Hard set values. eg. {x = number, y = number}
---@return SPAWN Returns self.
function SPAWN:AddUnit(TypeUnit, Name, Skill, Heading, CanDrive, Args)
    local unit = {}

    unit.type = TypeUnit or self.TypeUnit
    unit.skill = Skill or self.Skill
    unit.name = Name or string.format('%s-%s', self.Name, self.UnitIterator)
    unit.playerCanDrive = CanDrive or self.CanDrive
    unit.heading = Heading or math.rad(math.random(0, 359))

    if Args then
        for key, value in pairs(Args) do
            unit[key] = value
        end
    end

    table.insert(self.Units, unit)
    self:_Iterate()

    return self
end

--- Spawn the GROUP or STATIC object into the mission environment with a Vec2 coordinate.
---@param Vec2 Vec2 The coordinate in which to spawn the GROUP or STATIC.
---@return STATIC|GROUP Returns a GROUP or STATIC.
function SPAWN:SpawnFromVec2(Vec2)
    self.Vec2 = Vec2

    if not self.Static then
        if ROUTINES.util.size(self.Units) == 0 then return end

        for i, unit in ipairs(self.Units) do

            if i == 1 then
                if not unit.x and not unit.y then
                    unit.x = self.Vec2.x
                    unit.y = self.Vec2.z
                end
            else
                if not unit.x and not unit.y then
                    unit.x = self.Vec2.x + self.Offset.x
                    unit.y = self.Vec2.z + self.Offset.z
                    self.Offset.x = self.Offset.x + self.Offset.x
                    self.Offset.z = self.Offset.z + self.Offset.z
                end
            end
        end

        coalition.addGroup(self.Country, self.Category, self:_GetTemplate())

        return GROUP:FindByName(self.Name)
    else
        if self.FARP then
            coalition.addGroup(self.Country, -1, self:_GetTemplate())
            __DATABASE:Add(__DATABASE._Airbases, self.Name, AIRBASE, self.Name)
            __DATABASE:Add(__DATABASE._Statics, self.Name, STATIC, self.Name)

            return STATIC:FindByName(self.Name)
        else
            coalition.addStaticObject(self.Country, self:_GetTemplate())

            return STATIC:FindByName(self.Name)
        end
    end
end

--- Spawn the GROUP or STATIC object into the mission environment with a zone.
---@param Zone ZONE The zone in which to spawn the GROUP or STATIC.
---@return STATIC|GROUP Returns a GROUP or STATIC.
function SPAWN:SpawnFromZone(Zone)
    local Vec2 = Zone:GetVec2()

    return self:SpawnFromVec2(Vec2)
end

function SPAWN:SpawnFromZoneRandomVec2(Zone, SurfaceType)
    local Vec2 = Zone:GetRandomVec2(SurfaceType)

    if Vec2 then
        return self:SpawnFromVec2(Vec2)
    end

    return nil
end

--- Modify the SPAWN class default offsets.
---@param Args table The offset values to change. eg. {x = 10, y = -5} or {x = 2}.
---@return SPAWN Returns self.
function SPAWN:SetOffset(Args)
    local Vec2x = self.Offset.x
    local Vec2z = self.Offset.z

    if type(Args) == 'table' then
        if Args.x then
            Vec2x = Args.x
        end

        if Args.z then
            Vec2z = Args.z
        end

        self.Offset = {x = Vec2x, z = Vec2z}
    end

    return self
end

function SPAWN:_GetTemplate()
    local template = {}

    if not self.Static then
        template.tasks = {}
        template.units = self.Units
        template.name = self.Name
    else
        template.type = self.TypeUnit
        template.category = self.Category
        template.x = self.Vec2.x
        template.y = self.Vec2.z
        template.heading = self.Heading
        template.name = self.Name

        if self.ShapeFile then
            template.shape_name = self.ShapeFile
        end

        if self.Livery then
            template.livery_id = self.Livery
        end

        if self.FARP then
            local group = {}

            template.heliport_callsign_id = self.Callsign
            template.heliport_frequency = self.Freq
            template.heliport_modulation = self.Mod
            group.units = {}
            group.units[1] = template
            group.name = self.Name

            return group
        end
    end

    return template
end

function SPAWN:_Iterate()
    self.UnitIterator = self.UnitIterator + 1
end
