Utils = {
    dependencies = {}
}

function Utils:init()

end

function Utils:isInTable(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end

    return false
end

function Utils:areAllValuesInTable(table1, table2)
    local countTable = {}

    -- Create a count table for table2
    for _, value in pairs(table2) do
        if countTable[value] then
            countTable[value] = countTable[value] + 1
        else
            countTable[value] = 1
        end
    end

    -- Check that each value in table1 is present in the count table
    for _, value in pairs(table1) do
        if not countTable[value] or countTable[value] == 0 then
            return false
        end

        countTable[value] = countTable[value] - 1
    end

    return true
end

function Utils:areTablesEqual(table1, table2)
    -- Check if the tables have the same size
    if #table1 ~= #table2 then
        return false
    end

    -- Check if the tables have the same elements
    for i = 1, #table1 do
        if table1[i] ~= table2[i] then
            return false
        end
    end

    return true
end

function Utils:lenghtOfTable(tbl)
    local i = 0

    for _, v in pairs(tbl) do
        i = i + 1
    end
    return i
end

function Utils:uuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'

    local function randomHexDigit(c)
        if c == 'x' then
            return string.format('%x', global:random(0, 15))
        elseif c == 'y' then
            return string.format('%x', global:random(8, 11))
        end
    end

    local ret = string.gsub(template, '[xy]', randomHexDigit)
    return ret
end

function Utils:convertNumberKeysToStrings(t)
    local newTable = {}
    for k, v in pairs(t) do
        if type(k) == "number" then
            k = tostring(k)
        end
        if type(v) == "table" then
            newTable[k] = self:convertNumberKeysToStrings(v)
        else
            newTable[k] = v
        end
    end
    return newTable
end

function Utils:convertNumberValueToStrings(t)
    local newTable = {}
    for k, v in pairs(t) do
        if type(v) == "number" then
            v = tostring(v)
        end
        if type(v) == "table" then
            newTable[k] = self:convertNumberValueToStrings(v)
        else
            newTable[k] = v
        end
    end
    return newTable
end

function Utils:stringToTable(str)
    local tbl = {}
    for k, v in string.gmatch(str, "(%w+):(%w+)") do
        tbl[k] = v == "true"
    end
    return tbl
end

function Utils:tableToString(table)
    local str = ""
    for k,v in pairs(table) do
        str = str..tostring(k)..":"..tostring(v)..","
    end
    return str
end

function Utils:countIdenticalItems(tbl)
    local count = {}
    for _, item in ipairs(tbl) do
        local itemStr = self:tableToString(item)
        if count[itemStr] then
            count[itemStr] = count[itemStr] + 1
        else
            count[itemStr] = 1
        end
    end
    return count
end

function Utils:measureExecutionTime(functionToExecute, ...)
    local startTime = os.clock()
    local results = { functionToExecute(...) }
    local endTime = os.clock()
    local executionTime = endTime - startTime

    return executionTime, unpack(results)
end

function Utils:split(str, delimiter)
    local result = {}
    for match in (str..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

return Utils