local class = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\Class.lua]])

local list = class('List', {
    items = {}
})

-- Constructeur de la classe List
function list:init()
    if self.logger then
        self.logger = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\utils\Logger.lua]])()
    end
end

-- Méthode pour ajouter un élément à la liste
function list:add(item)
    -- if self.logger then
    --     self.logger:log("Test")
    -- end
    table.insert(self.items, item)
end

-- Méthode pour obtenir un élément à un index spécifique
function list:get(index)
    return self.items[index]
end

-- Méthode pour supprimer un élément à un index spécifique
function list:remove(index)
    table.remove(self.items, index)
end

-- Méthode pour obtenir la taille de la liste
function list:size()
    return #self.items
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
end

function list:reverse()
    local reversed = {}
    for i = #self.items, 1, -1 do
        table.insert(reversed, self.items[i])
    end
    self.items = reversed
end

function list:sort(comparator)
    table.sort(self.items, comparator)
end

function list:clear()
    self.items = {}
end

function list:map(func)
    local mapped = list()
    for _, item in ipairs(self.items) do
        mapped:add(func(item))
    end
    return mapped
end

function list:filter(predicate)
    local filtered = list()
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
end

function list:nFirstItems(n)
    local firstItems = list()
    for i = 1, math.min(n, #self.items) do
        firstItems:add(self.items[i])
    end
    return firstItems
end

function list:nLastItems(n)
    local lastItems = list()
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
    local newList = list()
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

    local newList = list()
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

function list.fromTable(tbl)
    local newList = list()
    for _, item in ipairs(tbl) do
        newList:add(item)
    end
    return newList
end

return list
