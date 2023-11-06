local stack = {
    dependencies = { "node" }
}

function stack:init()
    self.top = nil
    self.size = 0
end

-- Méthode pour ajouter un élément en haut de la pile
function stack:push(value)
    local node = self.node(value)
    node.next = self.top
    self.top = node
    self.size = self.size + 1
    --self.logger:log(node.value)
end

-- Méthode pour retirer l'élément en haut de la pile
function stack:pop()
    if self:isEmpty() then
        return nil
    end
    local value = self.top.value
    self.top = self.top.next
    self.size = self.size - 1
    return value
end

-- Méthode pour vérifier si la pile est vide
function stack:isEmpty()
    return self.size == 0
end

-- Méthode pour obtenir l'élément en haut de la pile sans le retirer
function stack:peek()
    if self:isEmpty() then
        return nil
    end
    return self.top.value
end

-- Convert the stack to a list
function stack:toList()
    local list = {}
    local current = self.top
    while current ~= nil do
        table.insert(list, current.value)
        current = current.next
    end
    return list
end

-- Create a stack from a list
function stack:fromList(list)
    local stack = self.newInstance()
    for i = #list, 1, -1 do
        stack:push(list[i])
    end
    return stack
end

-- Métaméthodes

-- Length
function stack.__len(self)
    return self.size
end

-- Equality
function stack.__eq(self, anotherStack)
    local list1 = self:toList()
    local list2 = anotherStack:toList()
    if #list1 ~= #list2 then
        return false
    end
    for i = 1, #list1 do
        if list1[i] ~= list2[i] then
            return false
        end
    end
    return true
end

-- Addition
function stack.__add(self, other)
    local list1 = self:toList()
    local list2 = other:toList()
    local result = self:fromList(table.move(list2, 1, #list2, #list1 + 1, list1))
    return result
end

-- Pairs
function stack.__pairs(self)
    return self:iterator()
end

-- IPairs
function stack.__ipairs(self)
    return self:iterator()
end

-- Iterator
function stack:iterator()
    local index = 0
    local current = self.top
    return function()
        if current ~= nil then
            local value = current.value
            current = current.next
            index = index + 1
            return index, value
        end
    end
end


return stack