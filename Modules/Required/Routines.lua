---@author West#9009
---@description Routinely used functions.
---@created 16MAY22

---@class ROUTINES
---@field public util table Utility functions.
---@field public file table File functions.
ROUTINES = {}
ROUTINES.util = {}
ROUTINES.file = {}

---@param object table The object or table to copy.
---@return table The new table with copied metatables.
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

---@param fileName string The file name to test.
---@return boolean Is file?
ROUTINES.file.isFile = function(fileName)
    if lfs.attributes(fileName) then
        return true
        else
        return false 
    end 
end

---@param dirName string The directory name to test.
---@return boolean Is directory?
ROUTINES.file.isDir = function(dirName)
    if lfs.attributes(dirName:gsub("\\$",""),"mode") == "directory" then
        return true
    else
        return false
    end
end
