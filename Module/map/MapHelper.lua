local mapHelper = {
    dependencies = { "utils", "list", "dictionary" },
    cellArray = {}
}

function mapHelper:init()
    self.directions = self.list()
    self.gatherElements = self.dictionary()
    local interactiveString = dofile(global:getCurrentDirectory() .. [[Sandbox\YayaToolsV3\Data\Interactives.lua]])

    for line in interactiveString:gmatch("[^\r\n]+") do
        local parts = self.utils:split(line, " - ")
        if #parts > 0 then
            local key = parts[1]
            local value = ""
            for i = 3, #parts - 1 do
                value = value .. " " .. parts[i]
            end
            self.gatherElements:add(key, value)
        end
    end

    self.directions:add("left")
    self.directions:add("right")
    self.directions:add("top")
    self.directions:add("bottom")
    self:initCellsArray()
end

function mapHelper:initCellsArray()
    local width = 14
    local height = 40
    for cellId = 0, width * height - 1 do
        local x = cellId % width
        local y = math.floor(cellId / width)
        self.cellArray[cellId] = {x = x, y = y}
    end
end

function mapHelper:getWalkableZones()
    local movableCells = map:getWalkableCells(false)
    local visited = {}
    local zones = {}

    for _, cell in pairs(movableCells) do
        if not visited[cell] then
            local zone = self:dfs(cell, visited, movableCells)
            table.insert(zones, zone)
        end
    end
    --collectgarbage("collect")
    return zones
end

function mapHelper:dfs(cell, visited, movableCells)
    local stack = {cell}
    local zone = {}

    while #stack > 0 do
        local current = table.remove(stack)

        if not visited[current] then
            visited[current] = true
            table.insert(zone, current)

            local adjacentCells = self:getAdjacentCells(current)

            for _, adjacentCell in pairs(adjacentCells) do
                if self.utils:isInTable(movableCells, adjacentCell) and not visited[adjacentCell] then
                    if self:isDiagonalWalkable(current, adjacentCell) then
                        table.insert(stack, adjacentCell)
                    end
                end
            end
        end
    end

    return zone
end

function mapHelper:isDiagonalWalkable(cell1, cell2)
    local walkableCell = map:getWalkableCells(false)

    local adjCell1 = self:getAdjacentCells(cell1)

    if cell1 < cell2 then -- Bas
        if not self.utils:isInTable(walkableCell, adjCell1["bg"]) and not self.utils:isInTable(walkableCell, adjCell1["bd"]) then
            return false
        end
    else -- Haut
        if not self.utils:isInTable(walkableCell, adjCell1["hg"]) and not self.utils:isInTable(walkableCell, adjCell1["hd"]) then
            return false
        end
    end
    walkableCell = nil
    return true
end

function mapHelper:getAdjacentCells(cellId)
    local coord = self:cellIdToCoord(cellId)
    local adjacentOffsets
    if coord.y % 2 == 0 then
        --self.logger:debug("pairs")
        adjacentOffsets = {
            ["g"] = {x = -1, y =  0},  -- Gauche
            ["d"] = {x =  1, y =  0},  -- Droite
            ["h"] = {x =  0, y = -2},  -- Haut
            ["b"] = {x = 0, y = 2},   -- Bas
            ["hg"] = {x =  -1, y = -1},  -- Haut gauche
            ["bg"] = {x =  -1, y = 1},  -- Bas gauche
            ["hd"] = {x =  0, y = -1},  -- Haut droite
            ["bd"] = {x = 0, y = 1}   -- Bas droit
        }
    else
        --self.logger:debug("impairs")
        adjacentOffsets = {
            ["g"] = {x = -1, y =  0},  -- Gauche
            ["d"] = {x =  1, y =  0},  -- Droite
            ["h"] = {x =  0, y = -2},  -- Haut
            ["b"] = {x = 0, y = 2},   -- Bas
            ["hg"] = {x =  0, y = -1},  -- Haut gauche
            ["bg"] = {x =  0, y = 1},  -- Bas gauche
            ["hd"] = {x =  1, y = -1},  -- Haut droite
            ["bd"] = {x = 1, y = 1}   -- Bas droit
        }
    end

    local adjacentCells = {}
    for k, offset in pairs(adjacentOffsets) do
        local adjCoord = {x = coord.x + offset.x, y = coord.y + offset.y}
        if self:isCoordValid(adjCoord) then
            local adjCellId = adjCoord.y * 14 + adjCoord.x
            adjacentCells[k] = adjCellId
        end
    end

    return adjacentCells
end

function mapHelper:cellsBFSUntil(cell, targetCells)
    local visited = {}
    local queue = {cell}

    while #queue > 0 do
        local current = table.remove(queue, 1)
        if not visited[current] then
            visited[current] = true

            if self.utils:isInTable(targetCells, current) then
                return current  -- Found a target cell, return it
            end

            local adjacentCells = self:getAdjacentCells(current)

            for _, adjacentCell in pairs(adjacentCells) do
                if not visited[adjacentCell] then
                    table.insert(queue, adjacentCell)
                end
            end
        end
    end

    return nil  -- No target cells were found
end

function mapHelper:getOppositeDirection(dir)
    if dir == "left" then
        return "right"
    elseif dir == "right" then
        return "left"
    elseif dir == "top" then
        return "bottom"
    elseif dir == "bottom" then
        return "top"
    end
end

function mapHelper:getZoneDirections(zone)
    local directions = {}

    for _, cellId in pairs(zone) do
        local coord = self:CellIdToCoord(cellId)
        local cellIdFromCoord = self:CoordToCellId(coord)

        -- If the cell is on the top row of the map, note that we can move up
        if cellIdFromCoord < 28 then
            directions["top"] = true
        end

        -- If the cell is on the bottom row of the map, note that we can move down
        if cellIdFromCoord >= 532 then
            directions["bottom"] = true
        end

        -- If the cell is on the left column of the map, note that we can move left
        if cellIdFromCoord % 14 == 0 then
            directions["left"] = true
        end

        -- If the cell is on the right column of the map, note that we can move right
        if cellIdFromCoord % 14 == 13 then
            directions["right"] = true
        end
    end

    return directions
end

function mapHelper:cellIdToCoord(cellId)
    if self:isCellIdValid(cellId) then
        return self.cellArray[cellId]
    end

    return nil
end

function mapHelper:isCellIdValid(cellId)
	return (cellId >= 0 and cellId < 560)
end

function mapHelper:isCoordValid(coord)
    local width = 14
    local height = 40
    --return true
    return coord.x >= 0 and coord.y >= 0 and coord.x < width and coord.y < height
end

function mapHelper:getCellDirection(cellId)
    local coord = self:cellIdToCoord(cellId)
    local width = 14
    local height = 40
    local directions = {}

    -- If the cell is on the top row of the map, note that it's in the 'top' direction
    if coord.y <= 20 then
        directions["top"] = true
    else
        directions["bottom"] = true
    end

    -- If the cell is on the left column of the map, note that it's in the 'left' direction
    if coord.x <= 7 then
        directions["left"] = true
    else
        directions["right"] = true
    end

    return directions
end

function mapHelper:possibleDirections(cellId)
    local coord = self:cellIdToCoord(cellId)
    local directions = {}

    -- If the cell is on the top row of the map, note that it's in the 'top' direction
    if coord.y == 0 or coord.y == 1 then
        directions["top"] = "top"
    elseif coord.y == 38 or coord.y == 39 then
        directions["bottom"] = "bottom"
    end

    -- If the cell is on the left column of the map, note that it's in the 'left' direction
    if coord.x == 0 then
        directions["left"] = "left"
    elseif coord.x == 13 then
        directions["right"] = "right"
    end

    return directions
end

function mapHelper:getGatherElements()
    local m = map:getMap()
    local statedElements = self.dictionary()
    for _, statedElement in pairs(m.statedElements) do
        local stated = {
            elementId = statedElement.elementId,
            elementCellId = statedElement.elementCellId,
            elementState = statedElement.elementState,
            onCurrentMap = statedElement.onCurrentMap
        }
        statedElements:add(tostring(statedElement.elementId), stated)
    end

    local ret = {}
    for _, interactive in pairs(m.integereractiveElements) do
        local stated = statedElements:get(tostring(interactive.elementId))

        if stated and interactive.onCurrentMap and stated.onCurrentMap  then
            local elementName = self.gatherElements:get(tostring(interactive.elementTypeId))
            if elementName then
                if ret[elementName] == nil then
                    ret[elementName] = {
                        count = 1,
                        typeId = interactive.elementTypeId
                    }
                else
                    ret[elementName].count = ret[elementName].count + 1
                end
            end
        end
    end
    return ret
end

function mapHelper:getGatherElementsByZone()
    local walkableZones = self:getWalkableZones()
    local m = map:getMap()

    local ret = {}
    for _, interactive in pairs(m.integereractiveElements) do
        local elementName = self.gatherElements:get(tostring(interactive.elementTypeId))
        if elementName then
            for _, statedElement in pairs(m.statedElements) do
                if interactive.elementId == statedElement.elementId and interactive.onCurrentMap then
                    if ret[elementName] == nil then
                        ret[elementName] = {
                            count = 1,
                            typeId = interactive.elementTypeId,
                            cells = {statedElement.elementCellId}
                        }
                    else
                        ret[elementName].count = ret[elementName].count + 1
                        table.insert(ret[elementName].cells, statedElement.elementCellId)
                    end
                    break
                end
            end
        end
    end

    local countInteractive = {}
    for i, zone in pairs(walkableZones) do
        for _, interactiveElement in pairs(ret) do
            for _, interactiveCell in pairs(interactiveElement.cells) do
                if self:cellsBFSUntil(interactiveCell, zone) then
                    local elementName = self.gatherElements:get(tostring(interactiveElement.typeId))
                    if countInteractive[i] == nil then
                        countInteractive[i] = {}
                    end
                    if countInteractive[i][elementName] == nil then
                        countInteractive[i][elementName] = { name = elementName, typeId = interactiveElement.typeId, count = 1 }
                    else
                        countInteractive[i][elementName].count = countInteractive[i][elementName].count + 1
                    end

                end
            end
        end
    end

    return countInteractive
end

return mapHelper