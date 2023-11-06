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
    local ret = string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and global:random(0, 0xf) or global:random(8, 0xb)
        if c == 'y' then
            v = bit32.bor(bit32.band(v, 0x3), 0x8)
        end
        return string.format('%x', v)
    end)
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

function Utils:measureExecutionTime(functionToExecute, ...)
    local startTime = os.clock()
    local results = { functionToExecute(...) }
    local endTime = os.clock()
    local executionTime = endTime - startTime

    return executionTime, unpack(results)
end

return Utils