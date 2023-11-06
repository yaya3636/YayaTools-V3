local priorityQueue = {
    dependencies = {}
}

function priorityQueue:init()
    self.heap = {}
end

function priorityQueue:put(item, priority)
    table.insert(self.heap, {item=item, priority=priority})
    self:heapifyUp(#self.heap)
end

function priorityQueue:pop()
    if #self.heap == 0 then
        return nil
    end
    local topPriority = self.heap[1].item
    self.heap[1] = self.heap[#self.heap]
    table.remove(self.heap)
    self:heapifyDown(1)
    return topPriority
end

function priorityQueue:isEmpty()
    return #self.heap == 0
end

function priorityQueue:heapifyUp(index)
    while index > 1 do
        local parentIndex = math.floor(index / 2)
        if self.heap[parentIndex].priority > self.heap[index].priority then
            self.heap[parentIndex], self.heap[index] = self.heap[index], self.heap[parentIndex]
            index = parentIndex
        else
            break
        end
    end
end

function priorityQueue:heapifyDown(index)
    while true do
        local childIndex = 2 * index
        if childIndex > #self.heap then
            break
        end
        if childIndex + 1 <= #self.heap and self.heap[childIndex + 1].priority < self.heap[childIndex].priority then
            childIndex = childIndex + 1
        end
        if self.heap[childIndex].priority < self.heap[index].priority then
            self.heap[childIndex], self.heap[index] = self.heap[index], self.heap[childIndex]
            index = childIndex
        else
            break
        end
    end
end

return priorityQueue