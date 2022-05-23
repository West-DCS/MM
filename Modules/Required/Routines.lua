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

function ROUTINES.util.basicSerialize(var)
    if var == nil then
        return "\"\""
    else
        if ((type(var) == 'number') or
                (type(var) == 'boolean') or
                (type(var) == 'function') or
                (type(var) == 'table') or
                (type(var) == 'userdata') ) then
            return tostring(var)
        elseif type(var) == 'string' then
            var = string.format('%q', var)
            return var
        end
    end

end

function ROUTINES.util.oneLineSerialize(tbl)
    if type(tbl) == 'table' then

        local tbl_str = {}

        tbl_str[#tbl_str + 1] = '{ '

        for ind, val in pairs(tbl) do
            if type(ind) == "number" then
                tbl_str[#tbl_str + 1] = '['
                tbl_str[#tbl_str + 1] = tostring(ind)
                tbl_str[#tbl_str + 1] = '] = '
            else
                tbl_str[#tbl_str + 1] = '['
                tbl_str[#tbl_str + 1] = ROUTINES.util.basicSerialize(ind)
                tbl_str[#tbl_str + 1] = '] = '
            end

            if ((type(val) == 'number') or (type(val) == 'boolean')) then
                tbl_str[#tbl_str + 1] = tostring(val)
                tbl_str[#tbl_str + 1] = ', '
            elseif type(val) == 'string' then
                tbl_str[#tbl_str + 1] = ROUTINES.util.basicSerialize(val)
                tbl_str[#tbl_str + 1] = ', '
            elseif type(val) == 'nil' then
                tbl_str[#tbl_str + 1] = 'nil, '
            elseif type(val) == 'table' then
                tbl_str[#tbl_str + 1] = ROUTINES.util.oneLineSerialize(val)
                tbl_str[#tbl_str + 1] = ', '
            else

            end
        end
        tbl_str[#tbl_str + 1] = '}'
        return table.concat(tbl_str)
    else
        return  ROUTINES.util.basicSerialize(tbl)
    end
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
