local aStar = {
    dependencies = { "list", "dictionary", "aStarNode" }
}

function aStar:init(maps)
    self.nodes = self.list()
    self.visitedMaps = self.list()
    self.openList = self.list()
    self.closedList = self.list()
    self.excludedMapIds = self.list()

    local function getNeighbourId(mapId)
        local dir = { "LeftNeighbourId", "RightNeighbourId", "BottomNeighbourId", "TopNeighbourId" }
        local neighborId = self.list()
        local mapData = d2data:mapData(mapId)

        for _, v in pairs(dir) do
            if mapData[v] ~= 0 and maps:contains(mapData[v]) then
                neighborId:add(tonumber(mapData[v]))
            end
        end
        return neighborId
    end

    for _, v in pairs(maps) do
        self.nodes:add(self.aStarNode(v, getNeighbourId(v)))
    end
end

function aStar:findPath(startMapId, endMapId)
    self.openList:clear()
    self.closedList:clear()
    local startNode = self:getNodeByMapId(startMapId)
    local endNode = self:getNodeByMapId(endMapId)

    local neighborsFunc = function(node)
        local neighbors = self.list()
        for _, adjacentMapId in ipairs(node.adjacentMapIds) do
            if not self.excludedMapIds:contains(adjacentMapId) then
                local adjacentNode = self:getNodeByMapId(adjacentMapId)
                if adjacentNode then
                    neighbors:add(adjacentNode)
                end
            end
        end
        return neighbors
    end

    local costFunc = function(currentNode, neighborNode)
        local cost = map:GetPathDistance(currentNode.mapId, neighborNode.mapId)
        return cost
    end

    local heuristicFunc = function(currentNode, finishNode)
        local estimatedCost = map:GetPathDistance(currentNode.mapId, finishNode.mapId)
        return math.huge
    end

    return self:_findPath(startNode, endNode, neighborsFunc, costFunc, heuristicFunc)
end

function aStar:getNodeByMapId(mapId)
    for _, node in ipairs(self.nodes) do
        if node.mapId == mapId then
            return node
        end
    end
    return nil
end

function aStar:excludeMapId(mapId)
    self.excludedMapIds:add(mapId)
end

function aStar:_findPath(startNode, endNode, neighborsFunc, costFunc, heuristicFunc)
    self.openList:clear()
    self.closedList:clear()

    startNode.g = 0
    startNode.h = heuristicFunc(startNode, endNode)
    startNode.f = startNode.g + startNode.h
    self.openList:add(startNode)

    while not self.openList:isEmpty() do
        local currentNode = self:getLowestCostNode()

        if currentNode == endNode then
            return self:reconstructPath(currentNode)
        end

        self.openList:removeValue(currentNode)
        self.closedList:add(currentNode)

        local neighbors = neighborsFunc(currentNode)
        for _, neighbor in ipairs(neighbors) do
            if not self.closedList:contains(neighbor) then
                local tentativeG = currentNode.g + costFunc(currentNode, neighbor)

                if not self.openList:contains(neighbor) then
                    self.openList:add(neighbor)
                elseif tentativeG >= neighbor.g then
                    goto continue
                end

                neighbor.parent = currentNode
                neighbor.g = tentativeG
                neighbor.h = heuristicFunc(neighbor, endNode)
                neighbor.f = neighbor.g + neighbor.h
            end

            ::continue::
        end
    end

    return nil -- Pas de chemin trouvé
end

function aStar:getLowestCostNode()
    local lowestCostNode = self.openList:get(1)
    local lowestCost = lowestCostNode.f

    for i = 2, self.openList:length() do
        local currentNode = self.openList:get(i)
        if currentNode.f < lowestCost then
            lowestCostNode = currentNode
            lowestCost = currentNode.f
        end
    end

    return lowestCostNode
end

function aStar:reconstructPath(node)
    local path = self.list()
    while node do
        self:excludeMapId(node.mapId)
        path:add(node.mapId) -- Ajoute le mapId du noeud au lieu du noeud lui-même
        node = node.parent
    end
    self.excludedMapIds:reverse():remove(#self.excludedMapIds)
    return path:reverse() -- Inverse la liste pour avoir les mapId dans le bon ordre
end

return aStar