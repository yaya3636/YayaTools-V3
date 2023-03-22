local linkedList = {
    dependencies = {"node", "list"}
}

function linkedList:init()
    self.head = nil
    self.tail = nil
end

function linkedList:append(value)
    local newNode = self.node(value)
    if not self.head then
        self.head = newNode
        self.tail = newNode
    else
        self.tail.next = newNode
        self.tail = newNode
    end
    return self
end

function linkedList:insert(value)
    self:insertAt(1, value)
    return self
end

function linkedList:insertAt(index, value)
    if index < 1 then
        return false
    end

    local newNode = self.node(value)
    local current = self.head
    local prev = nil
    local i = 1

    if index == 1 then
        newNode.next = self.head
        self.head = newNode
        if not self.tail then
            self.tail = newNode
        end
        return true
    end

    while current and i < index do
        prev = current
        current = current.next
        i = i + 1
    end

    if current or (not current and i == index) then
        newNode.next = current
        prev.next = newNode
        if not current then
            self.tail = newNode
        end
        return true
    end

    return false
end

function linkedList:get(index)
    local current = self.head
    local i = 1

    while current and i < index do
        current = current.next
        i = i + 1
    end

    if current then
        return current.value
    end

    return nil
end

function linkedList:length()
    local count = 0
    local current = self.head

    while current do
        count = count + 1
        current = current.next
    end

    return count
end

function linkedList:isEmpty()
    return self.head == nil
end

function linkedList:removeAt(index)
    if index < 1 or not self.head then
        return false
    end

    local current = self.head
    local prev = nil
    local i = 1

    if index == 1 then
        self.head = current.next
        if not self.head then
            self.tail = nil
        end
        return true
    end

    while current and i < index do
        prev = current
        current = current.next
        i = i + 1
    end

    if current then
        prev.next = current.next
        if not current.next then
            self.tail = prev
        end
        return true
    end

    return false
end

function linkedList:clear()
    self.head = nil
    self.tail = nil
    return self
end

function linkedList:indexOf(value)
    local index = 1
    local current = self.head

    while current do
        if current.value == value then
            return index
        end
        current = current.next
        index = index + 1
    end

    return -1
end

function linkedList:reverse()
    local prev = nil
    local current = self.head
    local nextNode

    self.tail = self.head

    while current do
        nextNode = current.next
        current.next = prev
        prev = current
        current = nextNode
    end

    self.head = prev
    return self
end

function linkedList:map(callback)
    local newList = self.newInstance()
    local current = self.head

    while current do
        newList:append(callback(current.value))
        current = current.next
    end

    return newList
end

function linkedList:filter(predicate)
    local newList = self.newInstance()
    local current = self.head

    while current do
        if predicate(current.value) then
            newList:append(current.value)
        end
        current = current.next
    end

    return newList
end

function linkedList:find(predicate)
    local current = self.head

    while current do
        if predicate(current.value) then
            return current.value
        end
        current = current.next
    end

    return nil
end

function linkedList:contains(value)
    local current = self.head

    while current do
        if current.value == value then
            return true
        end
        current = current.next
    end

    return false
end

function linkedList:toList()
    local list = self.list()
    local current = self.head

    while current do
        list:add(current.value)
        current = current.next
    end

    return list
end

function linkedList:fromList(array)
    local newList = self.newInstance()

    for _, value in ipairs(array) do
        newList:append(value)
    end

    return newList
end

function linkedList:clone()
    local newList = self.newInstance()
    local current = self.head

    while current do
        newList:append(current.value)
        current = current.next
    end

    return newList
end

function linkedList:iterator()
    local current = self.head
    local index = 1

    return function()
        if not current then
            return nil
        end
        local value = current.value
        local currentIndex = index
        current = current.next
        index = index + 1
        return currentIndex, value
    end
end

function linkedList.__pairs(self)
    return self:iterator()
end

function linkedList.__ipairs(self)
    return self:iterator()
end

function linkedList.__len(self)
    return self:length()
end

function linkedList.__eq(self, otherList)
    local currentA = self.head
    local currentB = otherList.head

    while currentA and currentB do
        if currentA.value ~= currentB.value then
            return false
        end
        currentA = currentA.next
        currentB = currentB.next
    end

    return currentA == nil and currentB == nil
end

function linkedList.__add(self, other)
    local newList = self:clone()
    local current = other.head

    while current do
        newList:append(current.value)
        current = current.next
    end

    return newList
end

function linkedList.__sub(self, other)
    local newList = self:clone()
    local current = other.head

    while current do
        while newList:contains(current.value) do
            local index = newList:indexOf(current.value)
            newList:removeAt(index)
        end
        current = current.next
    end

    return newList
end

return linkedList