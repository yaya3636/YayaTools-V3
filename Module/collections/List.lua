local list = {}
-- Constructeur de la classe List
function list:init()
    self.items = {}
end
-- Méthode pour ajouter un élément à la liste
function list:add(item)
    -- if self.logger then
    --     self.logger:log("Test")
    -- end
    table.insert(self.items, item)
    return self
end

-- Méthode pour obtenir un élément à un index spécifique
function list:get(index)
    return self.items[index]
end

-- Méthode pour supprimer un élément à un index spécifique
function list:remove(index)
    table.remove(self.items, index)
    return self
end

function list:removeValue(value)
    local index = self:indexOf(value)
    while index do
        self:remove(index)
        index = self:indexOf(value)
    end
    return self
end


-- Méthode pour obtenir la taille de la liste
function list:length()
    local i = 0
    for _ in pairs(self.items) do
        i = i + 1
    end
    return i
end

function list:indexOf(item)
    for index, value in ipairs(self.items) do
        if value == item then
            return index
        end
    end
    return nil
end

function list:contains(item)
    return self:indexOf(item) ~= nil
end

function list:merge(anotherList)
    for _, item in ipairs(anotherList.items) do
        self:add(item)
    end
    return self
end

function list:reverse()
    local reversed = {}
    for i = #self.items, 1, -1 do
        table.insert(reversed, self.items[i])
    end
    self.items = reversed
    return self
end

function list:sort(comparator)
    table.sort(self.items, comparator)
    return self
end

function list:clear()
    self.items = {}
    return self
end

function list:map(func)
    local mapped = self.newInstance()
    for _, item in ipairs(self.items) do
        mapped:add(func(item))
    end
    return mapped
end

function list:filter(predicate)
    local filtered = self.newInstance()
    for _, item in ipairs(self.items) do
        if predicate(item) then
            filtered:add(item)
        end
    end
    return filtered
end

function list:forEach(func)
    for _, item in ipairs(self.items) do
        func(item)
    end
end

function list:last()
    return self.items[#self.items]
end

function list:removeItem(item)
    local index = self:indexOf(item)
    if index then
        self:remove(index)
    end
    return self
end

function list:nFirstItems(n)
    local firstItems = self.newInstance()
    for i = 1, math.min(n, #self.items) do
        firstItems:add(self.items[i])
    end
    return firstItems
end

function list:nLastItems(n)
    local lastItems = self.newInstance()
    local start = math.max(1, #self.items - n + 1)
    for i = start, #self.items do
        lastItems:add(self.items[i])
    end
    return lastItems
end

function list:isEmpty()
    return #self.items == 0
end

function list:copy()
    local newList = self.newInstance()
    for _, item in ipairs(self.items) do
        newList:add(item)
    end
    return newList
end

function list:every(predicate)
    for _, item in ipairs(self.items) do
        if not predicate(item) then
            return false
        end
    end
    return true
end

function list:some(predicate)
    for _, item in ipairs(self.items) do
        if predicate(item) then
            return true
        end
    end
    return false
end

function list:random()
    if self:isEmpty() then
        return 0
    end
    local index = global:random(1, #self.items)
    return self.items[index]
end

function list:unique()
    local uniqueItems = {}
    for _, item in ipairs(self.items) do
        if not uniqueItems[item] then
            uniqueItems[item] = true
        end
    end

    local newList = self.newInstance()
    for item, _ in pairs(uniqueItems) do
        newList:add(item)
    end
    return newList
end

function list:count(item)
    local count = 0
    for _, value in ipairs(self.items) do
        if value == item then
            count = count + 1
        end
    end
    return count
end

function list:fromTable(tbl)
    local newList = self.newInstance()
    for _, item in ipairs(tbl) do
        newList:add(item)
    end
    return newList
end

function list.__pairs(v)
    local key, value
    return function()
        key, value = next(v.items, key)
        return key, value
    end
end

function list.__ipairs(self)
    local function keysAsIndexIterator(dict, prevIdx)
        prevIdx = prevIdx + 1
        local key = dict.sortedKeys[prevIdx]

        if key then
            return prevIdx, dict.items[key]
        end
    end

    self.sortedKeys = {}
    for key in pairs(self.items) do
        table.insert(self.sortedKeys, key)
    end

    return keysAsIndexIterator, self, 0
end

function list.__len(self)
    return self:length()
end

function list.__eq(self, anotherList)
    if #self.items ~= #anotherList.items then
        return false
    end

    for index, value in ipairs(self.items) do
        if value ~= anotherList.items[index] then
            return false
        end
    end

    return true
end

function list.__add(self, other)
    local result = self:copy()
    result:merge(other)
    return result
end

function list.__sub(self, other)
    local result = self:copy()
    for _, value in ipairs(other.items) do
        while result:contains(value) do
            result:removeValue(value)
        end
    end
    return result
end


return list
