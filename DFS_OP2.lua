local moduleLoader = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\ModuleLoader.lua]])(2)
logger = moduleLoader:load("logger")(1)
local json = moduleLoader:load("Json")()
Packet = moduleLoader:load("PacketManager")
Areas = moduleLoader:load("Areas")
SubAreas = moduleLoader:load("SubAreas")
--local ar = Areas:getAreaObjectByName("Amakna")
--local sb = SubAreas:getSubAreaObjectByName("Port de Madrestam")
--logger:printTable(ar)

logger:addHeaderColor("DFS", "#fff74d")

mapDirectory = global:getCurrentDirectory() .. [[\YayaToolsV3\Data\Maps\]]

directions = { "left", "right", "top", "bottom" }
visitedMaps = {}
stack = {}
mapPositionHashTable = {}
currentState = "explore"
countMove = 0
currentMapId = "0"
lastMapId = "0"
lastDirection = ""
stuckMap = {}
local currentZone = SubAreas:getSubAreaObjectByName(map:currentSubArea()).id
local currentAreaId = Areas:getAreaObjectByName(map:currentArea()).id


local file = io.open(mapDirectory .. "visitedMaps.json", "r")

logger:log("Récupération des maps exploré", "DFS", 2)

if file then
    local fileContent = file:read("*all")
    file:close()
    visitedMaps = json:decode(fileContent)
end

for _, mapData in pairs(visitedMaps) do
    local hashKey = mapData.pos.x .. "," .. mapData.pos.y
    mapPositionHashTable[hashKey] = mapData.mapId
end

logger:log("Récupération des maps exploré terminée", "DFS", 2)

-- Core

function updateVisitedMaps()
    local currentMapPos = { x = map:getX(tonumber(currentMapId)), y = map:getY(tonumber(currentMapId)) }

    if not visitedMaps[currentMapId] then
        visitedMaps[currentMapId] = {}
        visitedMaps[currentMapId].mapId = currentMapId
        visitedMaps[currentMapId].area = map:currentArea()
        visitedMaps[currentMapId].areaId = Areas:getAreaObjectByName(map:currentArea()).id
        visitedMaps[currentMapId].subArea = map:currentSubArea()
        visitedMaps[currentMapId].subAreaId = SubAreas:getSubAreaObjectByName(map:currentSubArea()).id
        visitedMaps[currentMapId].pos = currentMapPos
        local hashKey = currentMapPos.x .. "," .. currentMapPos.y
        mapPositionHashTable[hashKey] = currentMapId
        for _, dir in ipairs(directions) do
            visitedMaps[currentMapId][dir] = {
                visited = false,
                isBlocked = false
            }
        end
    end

    for _, dir in ipairs(directions) do
        local adjacentPosX, adjacentPosY = getAdjacentCoordinates(visitedMaps[currentMapId].pos.x,
            visitedMaps[currentMapId].pos.y, dir)

        -- Recherchez la carte adjacente dans la table de hachage
        local hashKey = adjacentPosX .. "," .. adjacentPosY
        local visitedMapId = mapPositionHashTable[hashKey]

        if visitedMapId and visitedMaps[visitedMapId] then
            local oppositeDir = getOppositeDirection(dir)

            if not visitedMaps[visitedMapId][oppositeDir].isBlocked and visitedMaps[visitedMapId][oppositeDir].visited then
                logger:log("Adjacent mapId déterminé | mapId : " ..
                    currentMapId .. ", direction : " .. dir .. ", toMapId : " .. visitedMapId, "DFS", 2)
                visitedMaps[currentMapId][dir].mapId = visitedMapId
                visitedMaps[currentMapId][dir].visited = true
            elseif visitedMaps[visitedMapId][oppositeDir].isBlocked and visitedMaps[visitedMapId][oppositeDir].visited then
                logger:log("Adjacent mapId blocked | mapId : " ..
                    currentMapId .. ", direction : " .. dir .. ", toMapId : " .. visitedMapId, "DFS", 2)
                visitedMaps[currentMapId][dir].visited = true
                visitedMaps[currentMapId][dir].isBlocked = true
            else
                logger:log("Impossible de déterminé la mapId Adjacente", "DFS", 2)
            end
        end
    end
end

function getNextDirection()
    local bestDirection = nil
    local bestPriority = math.huge

    for _, dir in ipairs(directions) do
        if not visitedMaps[currentMapId][dir].visited and not visitedMaps[currentMapId][dir].isBlocked then
            local adjacentPosX, adjacentPosY = getAdjacentCoordinates(visitedMaps[currentMapId].pos.x,
                visitedMaps[currentMapId].pos.y, dir)
            local hashKey = adjacentPosX .. "," .. adjacentPosY
            local adjacentMapId = mapPositionHashTable[hashKey]
            if adjacentMapId then
                --logger:log("AdjacentMapId : " .. adjacentMapId)
            end
            --logger:log("lastMapId : " .. lastMapId)

            local priority = 0
            if adjacentMapId and lastMapId == adjacentMapId then
                priority = 1
            elseif adjacentMapId and not isMapFullyExplored(visitedMaps[adjacentMapId]) then
                priority = 2
            else
                priority = 3
            end

            if priority < bestPriority then
                --logger:log("priority : " .. priority)
                bestDirection = dir
                bestPriority = priority
            end
        end
    end

    return bestDirection
end

function move()
    logger:log("Current State = " .. currentState, "DFS", 2)
    local actualSubAreaId = SubAreas:getSubAreaObjectByName(map:currentSubArea()).id
    currentMapId = tostring(map:currentMapId())
    countMove = countMove + 1
    if countMove >= 15 then
        countMove = 0
        exportVisitedMaps()
    end

    local stuckCounter = 0
    updateVisitedMaps()
    --logger:log("ActualZone = " .. actualSubAreaId, "DFS", 2)
    --logger:log("CurrentZone = " .. currentZone, "DFS", 2)
    if actualSubAreaId ~= currentZone then
        if not isSubAreaFullyExplored(currentZone) then
            logger:log("Zone non exploré, retour dans la sous zone prècedente", "DFS", 2)
            currentState = "backtrack"
        else
            currentZone = actualSubAreaId
        end
    end

    while true do
        local currentMapInfo = visitedMaps[currentMapId]

        if currentState == "explore" then
            if lastMapId ~= "0" and lastMapId ~= currentMapId then
                visitedMaps[lastMapId][lastDirection].mapId = currentMapId
            end

            local nextDirection = getNextDirection()
            --logger:log(nextDirection)
            if nextDirection then
                visitedMaps[currentMapId][nextDirection].visited = true
                table.insert(stack, { mapId = currentMapId, lastDirection = nextDirection })

                lastMapId = currentMapId
                lastDirection = nextDirection

                if not map:changeMap(nextDirection) then
                    lastMapId = "0"
                    visitedMaps[currentMapId][nextDirection].isBlocked = true
                    table.remove(stack, #stack)
                end
            else
                currentState = "backtrack"
                lastMapId = "0"
            end
        elseif currentState == "backtrack" then
            local targetMapId = nil

            for i = #stack, 1, -1 do
                local stackItem = stack[i]
                local mapId = stackItem.mapId

                if not isSubAreaFullyExplored(currentZone) then
                    if hasUnexploredDirection(visitedMaps[mapId]) and visitedMaps[mapId].subAreaId == currentZone then
                        targetMapId = mapId
                        break
                    end
                else
                    if hasUnexploredDirection(visitedMaps[mapId]) then
                        targetMapId = mapId
                        break
                    end
                end
            end

            if currentMapId == targetMapId then
                currentState = "explore"
                local targetIndex = nil
                stuckMap = {}
                stuckCounter = 0
                for i, stackItem in ipairs(stack) do
                    if stackItem.mapId == targetMapId then
                        targetIndex = i
                        break
                    end
                end

                if targetIndex then
                    stack = { unpack(stack, 1, targetIndex) }
                end
            elseif targetMapId then
                if stuckCounter >= 5 then
                    logger:log("Impossible de déplacer vers la mapId : " .. targetMapId, "DFS", 2)
                    table.insert(stuckMap, targetMapId)
                    stack = {}
                    stuckCounter = 0
                else
                    logger:log("targetMapId = " .. targetMapId)
                    map:moveToward(tonumber(targetMapId))
                end
            else
                logger:log("Recherche de la carte non explorée la plus proche")
                local closestUnexploredMapId = getUnexploredMapIdInSubArea(currentZone)
                if closestUnexploredMapId == nil then
                    logger:log("Impossible de trouver une carte non explorée proche dans la sous zone, recherche d'une carte non explorée aléatoire dans la zone")
                    closestUnexploredMapId = getUnexploredMapIdInArea(Areas:getAreaObjectByName(map:currentArea()).id)
                end
                if closestUnexploredMapId == nil then
                    logger:log("Impossible de trouver une carte non explorée proche dans la zone, recherche d'une carte non explorée aléatoire dans la zone")
                    closestUnexploredMapId = getClosestUnexploredMap()
                end
                if closestUnexploredMapId == nil then
                    logger:log("Impossible de trouver une carte non explorée dans la zone, recherche d'une carte non explorée aléatoire")
                    closestUnexploredMapId = findUnvisitedMapId()
                end
                if closestUnexploredMapId then
                    table.insert(stack, { mapId = closestUnexploredMapId, lastDirection = "" })
                else
                    currentState = "finished"
                    logger:log("Exploration terminée. Toutes les cartes ont été explorées.")
                end
                -- logger:log("Recherche d'une map non exploré")
                -- local unexploredMapId = findUnvisitedMapId()
                -- table.insert(stack, { mapId = unexploredMapId, lastDirection = "" })
            end
        elseif currentState == "finished" then
            break
        end
        stuckCounter = stuckCounter + 1
    end
end

function stopped()
    exportVisitedMaps()
end

-- Area

function getUnexploredMapIdInSubArea(id)
    for mapId, mapInfo in pairs(visitedMaps) do
        if mapInfo.subAreaId == id and hasUnexploredDirection(mapInfo) then
            return mapInfo.mapId
        end
    end
end

function isCurrentSubAreaFullyExplored()
    local id = SubAreas:getSubAreaObjectByName(map:currentSubArea()).id
    local ret = true
    for mapId, mapInfo in pairs(visitedMaps) do
        if mapInfo.areaId == id and hasUnexploredDirection(mapInfo) then
            ret = false
            break
        end
    end
    return ret
end

function isSubAreaFullyExplored(id)
    for mapId, mapInfo in pairs(visitedMaps) do
        if mapInfo.subAreaId == id and hasUnexploredDirection(mapInfo) then
            return false
        end
    end
    return true
end

-- Maps

function isMapFullyExplored(mapInfo)
    for _, dir in ipairs(directions) do
        if not mapInfo[dir].visited and not mapInfo[dir].isBlocked then
            return false
        end
    end
    return true
end

function findUnvisitedMapId()
    for k, v in pairs(visitedMaps) do
        for _, dir in pairs(directions) do
            if not v[dir].visited and not v[dir].isBlocked then
                return k
            end
        end
    end
    currentState = "finished"
    logger:log("Exploration terminée. Toutes les cartes ont été explorées.")
end

function getClosestUnexploredMap()
    local closestMapId = nil
    local minDistance = math.huge
    local currentPos = { x = visitedMaps[currentMapId].pos.x, y = visitedMaps[currentMapId].pos.y }

    for _, mapData in pairs(visitedMaps) do
        for _, dir in ipairs(directions) do
            if not isSubAreaFullyExplored(currentZone) then
                if mapData.subAreaId == currentZone and not mapData[dir].visited and not mapData[dir].isBlocked and not contains(stuckMap, mapData.mapId) then
                    local adjacentPosX, adjacentPosY = getAdjacentCoordinates(mapData.pos.x, mapData.pos.y, dir)
                    local posKey = adjacentPosX .. "," .. adjacentPosY

                    if not mapPositionHashTable[posKey] then
                        local distance = math.abs(currentPos.x - adjacentPosX) + math.abs(currentPos.y - adjacentPosY)

                        if distance < minDistance then
                            minDistance = distance
                            closestMapId = mapData.mapId
                        end
                    end
                end
                --logger:log("Ici")
            else
                if not mapData[dir].visited and not mapData[dir].isBlocked and not contains(stuckMap, mapData.mapId) then
                    local adjacentPosX, adjacentPosY = getAdjacentCoordinates(mapData.pos.x, mapData.pos.y, dir)
                    local posKey = adjacentPosX .. "," .. adjacentPosY

                    if not mapPositionHashTable[posKey] then
                        local distance = math.abs(currentPos.x - adjacentPosX) + math.abs(currentPos.y - adjacentPosY)

                        if distance < minDistance then
                            minDistance = distance
                            closestMapId = mapData.mapId
                        end
                    end
                end
            end
        end
    end
    --logger:log("closest = " .. closestMapId)
    return closestMapId
end

function getUnexploredMapIdInArea(id)
    for mapId, mapInfo in pairs(visitedMaps) do
        if mapInfo.areaId == id and hasUnexploredDirection(mapInfo) then
            return mapInfo.mapId
        end
    end
end

-- Direction | coord

function getUnexploredDirections(mapInfo)
    local unexploredDirections = {}
    for _, dir in pairs(directions) do
        if not mapInfo[dir].visited and not mapInfo[dir].isBlocked then
            table.insert(unexploredDirections, dir)
        end
    end
    return unexploredDirections
end

function hasUnexploredDirection(mapInfo)
    for _, dir in ipairs(directions) do
        if not mapInfo[dir].visited and not mapInfo[dir].isBlocked then
            return true
        end
    end
    return false
end

function getOppositeDirection(direction)
    local oppositeDirection = {
        left = "right",
        right = "left",
        top = "bottom",
        bottom = "top"
    }
    return oppositeDirection[direction]
end

function getAdjacentCoordinates(posX, posY, direction)
    if direction == "left" then
        return posX - 1, posY
    elseif direction == "right" then
        return posX + 1, posY
    elseif direction == "top" then
        return posX, posY - 1
    elseif direction == "bottom" then
        return posX, posY + 1
    end
end

-- Packet CallBack

function messagesRegistering()
    Packet:subscribePacket("TextInformationMessage", CB_TextInformationMessage)
    --Packet:subscribePacket("ChangeMapMessage", function() developer:suspendScriptUntil("TextInformationMessage", 100, true) end)
end

function CB_TextInformationMessage(msg)
    if msg.msgId == 158 then
        logger:warning("Zone d'alliance, impossible d'accèder a la carte suivante", "DFS")
        lastMapId = "0"
        visitedMaps[currentMapId][lastDirection].isBlocked = true
        table.remove(stack, #stack)
        --currentState = "backtrack"
        --move()
        global:finishScript()
        global:thisAccountController():startScript()
    end
end

-- Exportation JSON

function exportVisitedMaps()
    logger:log("Exportation des maps au format JSON", "DFS", 3)
    local areaMaps = {}
    local subAreaMaps = {}

    local visitedFile = io.open(mapDirectory .. "visitedMaps.json", "w")
    local encoded = json:encode(convertNumberKeysToStrings(visitedMaps))
    visitedFile:write(encoded)
    visitedFile:close()
    -- Sort
    for _, mapInfo in pairs(cleanVisited()) do
        local area = "[" .. mapInfo.areaId .. "]" .. mapInfo.area
        local subArea = "[" .. mapInfo.subAreaId .. "]" .. mapInfo.subArea

        if not areaMaps[area] then
            areaMaps[area] = {}
        end
        if not subAreaMaps[subArea] then
            subAreaMaps[subArea] = {}
        end

        table.insert(areaMaps[area], mapInfo)
        table.insert(subAreaMaps[subArea], mapInfo)
    end

    -- Areas
    for area, maps in pairs(areaMaps) do
        local fileName = mapDirectory .. "Areas\\" .. area .. ".json"
        local f = io.open(fileName, "w")
        f:write(json:encode(maps))
        f:close()
    end

    -- SubAreas
    for subArea, maps in pairs(subAreaMaps) do
        local fileName = mapDirectory .. "SubAreas\\" .. subArea .. ".json"
        local f = io.open(fileName, "w")
        f:write(json:encode(maps))
        f:close()
    end
end

function convertNumberKeysToStrings(t)
    local newTable = {}
    for k, v in pairs(t) do
        if type(k) == "number" then
            k = tostring(k)
        end
        if type(v) == "table" then
            newTable[k] = convertNumberKeysToStrings(v)
        else
            newTable[k] = v
        end
    end
    return newTable
end

function cleanVisited()
    local cleanedData = {}
    for mapId, mapInfo in pairs(visitedMaps) do
        cleanedData[mapId] = {
            mapId = mapInfo.mapId,
            area = mapInfo.area,
            areaId = mapInfo.areaId,
            subArea = mapInfo.subArea,
            subAreaId = mapInfo.subAreaId,
            posX = mapInfo.posX,
            posY = mapInfo.posY
        }
        for _, dir in ipairs(directions) do
            if mapInfo[dir].mapId then
                cleanedData[mapId][dir] = {
                    mapId = mapInfo[dir].mapId
                }
            end
        end
    end
    return cleanedData
end

function contains(table, element)
    for _, value in ipairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
