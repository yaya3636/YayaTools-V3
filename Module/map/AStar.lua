local aStar = {
    dependencies = { "list", "dictionary", "aStarNode", "areas", "subAreas" }
}

function aStar:init(maps)
    self.nodes = self.list()
    self.visitedMaps = self.list()
    self.openList = self.list()
    self.closedList = self.list()
    self.excludedMapIds = self.list()
    self.relaxList = self.list()
    self.allMapsInfo = self.areas:getAllMapsByDFS()
    local function getNeighbourId(mapId)
        local dir = { "left", "right", "top", "bottom" }
        local neighborId = self.list()
        local mapData = self.allMapsInfo:get(tostring(mapId))
        for _, v in pairs(dir) do
            if mapData.neighbours:get(v) ~= nil and maps:contains(mapData.neighbours:get(v)) then
                neighborId:add(mapData.neighbours:get(v))
            end
        end
        return neighborId
    end

    for _, v in pairs(maps) do
        self.nodes:add(self.aStarNode(v, getNeighbourId(v)))
    end
end

function aStar:findPath(startMapId, endMapId)
    if startMapId and endMapId then
        startMapId = tostring(startMapId)
        endMapId = tostring(endMapId)
        self.startMapId = tostring(startMapId)
        self.endMapId = tostring(endMapId)
    end
    self.openList:clear()
    self.closedList:clear()
    self.logger:log("Finding path from " .. tostring(startMapId) .. " to " .. tostring(endMapId), "AStar", 2)
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
            else
                --self.logger:log("Excluding map " .. tostring(adjacentMapId), "AStar")
            end
        end
        return neighbors
    end

    local costFunc = function(currentNode, neighborNode)
        --local cost = map:GetPathDistance(tonumber(currentNode.mapId), tonumber(neighborNode.mapId))
        return 1
    end

    local heuristicFunc = function(currentNode, finishNode)
        local estimatedCost = map:GetDistance(tonumber(currentNode.mapId), tonumber(finishNode.mapId))
        return estimatedCost
    end

    local path = self:_findPath(startNode, endNode, neighborsFunc, costFunc, heuristicFunc)
    if not path then
        self:relax()
        path = self:findPath(startMapId, endMapId)
    end

    return path
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


function aStar:relax()
    self.logger:log("Relaxing path", "AStar", 2)

    if self.relaxList:isEmpty() then
        self.relaxList:add(self.startMapId)
        self.relaxList:add(self.endMapId)
    end

    local newRelaxList = self.list()

    for _, mapId in ipairs(self.relaxList) do
        local currentNode = self:getNodeByMapId(mapId)

        if currentNode then
            if self.excludedMapIds:contains(currentNode.mapId) then
                self.excludedMapIds:removeValue(currentNode.mapId)
                newRelaxList:add(currentNode.mapId)
            end
            for _, adjacentMapId in ipairs(currentNode.adjacentMapIds) do
                if self.excludedMapIds:contains(adjacentMapId) then
                    self.excludedMapIds:removeValue(adjacentMapId)
                    newRelaxList:add(adjacentMapId)
                end
            end
        end
    end

    self.relaxList = newRelaxList
    if #self.excludedMapIds == 0 then
        self.logger:log("No more map to relax", "AStar", 2)
    end
    --self.logger:log("length of excludedMapIds: " .. #self.excludedMapIds, "AStar")
end



return aStar
