---@author West#9009
---@description Routinely used functions.
---@created 16MAY22

---@class ROUTINES
---@field public util table Utility functions.
---@field public file table File functions.
---@field public os table OS functions.
---@field public os table Git functions.
ROUTINES = {}
ROUTINES.util = {}
ROUTINES.file = {}
ROUTINES.os = {}
ROUTINES.git = {}
ROUTINES.string = {}

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

ROUTINES.util.size = function(table)
    local size = 0

    for _ in pairs(table) do
       size = size + 1
    end

    return size
end

---@param FilePath string The file name to test.
---@return boolean Is file?
ROUTINES.file.isFile = function(FilePath)
    local NoPathName = string.match(FilePath, "[^\\]+$")
    local Sub = string.sub(NoPathName, 1, 1)

    if lfs.attributes(FilePath, "mode") == "file" and Sub ~= '.' then
        return true
    else
        return false 
    end 
end

---@param dirName string The directory name to test.
---@return boolean Is directory?
ROUTINES.file.isDir = function(dirName)
    if lfs.attributes(dirName, "mode") == "directory" then
        return true
    else
        return false
    end
end

ROUTINES.file.EDSerialize = function(Name, Value, Level, File)
    if Level == nil then Level = "" end

    if Level ~= "" then Level = Level .."  " end

    File:write(Level, Name, " = ")

    if type(Value) == "number" or type(Value) == "string" or type(Value) == "boolean" then
        File:write(ROUTINES.util.basicSerialize(Value), ",\n")
    elseif type(Value) == "table" then
        File:write("\n" .. Level .. "{\n") -- create a new table

        for k,v in pairs(Value) do -- serialize its fields
            local key

            if type(k) == "number" then
                key = string.format("[%s]", k)
            else
                key = string.format("[%q]", k)
            end

            ROUTINES.file.EDSerialize(key, v, Level.."  ", File)
        end

        if Level == "" then
            File:write(Level .."} -- end of ".. Name .."\n")
        else
            File:write(Level .."}, -- end of " .. Name .."\n")
        end
    end
end

ROUTINES.file.EDSerializeToFile = function(FilePath, FileName, Table)
    local File = io.open(FilePath .. FileName, 'w')
    ROUTINES.file.EDSerialize(FileName, Table, nil, File)
    File:close()
end

ROUTINES.file.read = function(FilePath, FileName)
    local File = io.open(FilePath .. FileName, "r")
    local Contents = File:read("*all")

    File:close()

    return Contents
end

ROUTINES.file.write = function(FilePath, FileName, Contents)
    local File = io.open(FilePath .. FileName, "w")
    File:write(Contents)
    File:close()
end

ROUTINES.os.exec = function(cmd, args)
    args = args or ''

    local status = os.execute(string.format('%s %s', cmd, args))

    return status
end

ROUTINES.os.capture = function(cmd)
    local f = assert(io.popen(cmd, 'r'))
    local s = assert(f:read('*a'))
    f:close()

    return s
end

ROUTINES.os.rmdir = function(dir)
    return ROUTINES.os.exec(string.format('rd /s/q "%s"', dir))
end

-- ASCII only.
ROUTINES.os.copy = function(source, destination)
    return ROUTINES.os.exec(string.format('copy "%s" "%s"', source, destination))
end

ROUTINES.git.reset = function(path)
    return ROUTINES.os.exec(string.format('git -C %s reset -q --hard', path))
end

ROUTINES.git.update = function(path)
    ROUTINES.git.reset(path)
    return ROUTINES.os.exec(string.format('git -C %s pull -qa', path))
end

ROUTINES.git.clone = function(URL, destination)
    local argument = string.format('%s "%s"', URL, destination)
    return ROUTINES.os.exec('git clone -q', argument)
end

ROUTINES.git.raw = function(User, Repo, FilePath)
    local Header = '"Accept:application/vnd.github.v3.raw"'
    local Link = string.format('https://api.github.com/repos/%s/%s/contents/%s', User, Repo, FilePath)

    return ROUTINES.os.capture(string.format('curl -s -H %s %s', Header, Link))
end

ROUTINES.string.split = function(String, Sep)
    local Sep = Sep or '%s'

    local t = {}

    for String in string.gmatch(String, "([^"..Sep.."]+)") do
        table.insert(t, String)
    end

    return t
end
