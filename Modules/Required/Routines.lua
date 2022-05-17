--[[
@Module Routines

@Author West#9009

@Description
Routinely used functions.

@Created 16MAY22

@TODO
]]

ROUTINES = {}
ROUTINES.util = {}

-- Attribution: MIST https://github.com/mrSkortch/MissionScriptingTools
ROUTINES.util.deepCopy = function(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

ROUTINES.file.isFile = function(fileName)
    if lfs.attributes(fileName) then
        return true
        else
        return false 
    end 
end

ROUTINES.file.isDir = function(dirName)
    if lfs.attributes(dirName:gsub("\\$",""),"mode") == "directory" then
        return true
    else
        return false
    end
end
