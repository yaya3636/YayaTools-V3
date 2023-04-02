local moduleLoader = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\ModuleLoader.lua]])(2)
logger = moduleLoader:load("logger")(1)
local json = moduleLoader:load("Json")()
Packet = moduleLoader:load("PacketManager")()

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

local function countUnexploredDirections(mapInfo)
    local count = 0
    for _, dir in ipairs(directions) do
        if not mapInfo[dir].visited and not mapInfo[dir].isBlocked then
            count = count + 1
        end
    end
    return count
end


local function isMapFullyExplored(mapInfo)
    for _, dir in ipairs(directions) do
        if not mapInfo[dir].visited and not mapInfo[dir].isBlocked then
            return false
        end
    end
    return true
end
-- Modifiez la fonction getNextDirection pour prioriser la finition de l'exploration des cartes visitées
local function getNextDirection(mapInfo)
    local bestDirection = nil
    local bestPriority = math.huge

    for _, dir in ipairs(directions) do
        if not mapInfo[dir].visited and not mapInfo[dir].isBlocked then
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





local function hasUnexploredDirection(mapInfo)
    for _, dir in ipairs(directions) do
        if not mapInfo[dir].visited and not mapInfo[dir].isBlocked then
            return true
        end
    end
    return false
end

local function updateVisitedMaps()
    local currentMapPos = { x = map:getX(tonumber(currentMapId)), y = map:getY(tonumber(currentMapId)) }

    if not visitedMaps[currentMapId] then
        visitedMaps[currentMapId] = {}
        visitedMaps[currentMapId].mapId = currentMapId
        visitedMaps[currentMapId].area = map:currentArea()
        visitedMaps[currentMapId].subArea = map:currentSubArea()
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
            if not visitedMaps[visitedMapId][oppositeDir].isBlocked then
                logger:log("Adjacent mapId déterminé | mapId : " ..
                    currentMapId .. ", direction : " .. dir .. ", toMapId : " .. visitedMapId, "DFS", 2)
                visitedMaps[currentMapId][dir].mapId = visitedMapId
                visitedMaps[currentMapId][dir].visited = true
            else
                logger:log("Adjacent mapId blocked | mapId : " ..
                    currentMapId .. ", direction : " .. dir .. ", toMapId : " .. visitedMapId, "DFS", 2)
                    visitedMaps[currentMapId][dir].visited = true
                    visitedMaps[currentMapId][dir].isBlocked = true

            end
        end
    end
end

function move()
    logger:log("Current State = " .. currentState, "DFS", 2)
    currentMapId = tostring(map:currentMapId())
    countMove = countMove + 1
    if countMove >= 15 then
        countMove = 0
        exportVisitedMaps()
    end

    while true do
        updateVisitedMaps()
        local currentMapInfo = visitedMaps[currentMapId]

        if currentState == "explore" then
            if lastMapId ~= "0" then
                visitedMaps[lastMapId][lastDirection].mapId = currentMapId
            end

            local nextDirection = getNextDirection(currentMapInfo)

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
            end
        elseif currentState == "backtrack" then
            local targetMapId = nil

            for i = #stack, 1, -1 do
                local stackItem = stack[i]
                local mapId = stackItem.mapId

                if hasUnexploredDirection(visitedMaps[mapId]) then
                    targetMapId = mapId
                    break
                end
            end

            if currentMapId == targetMapId then
                currentState = "explore"
                local targetIndex = nil
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
                map:moveToward(tonumber(targetMapId))
            else
                logger:log("Recherche de la carte non explorée la plus proche")
                local closestUnexploredMapId = getClosestUnexploredMap()

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
    end
end

function stopped()
    exportVisitedMaps()
end

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

function getOppositeDirection(direction)
    local oppositeDirection = {
        left = "right",
        right = "left",
        top = "bottom",
        bottom = "top"
    }
    return oppositeDirection[direction]
end

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
        local area = mapInfo.area
        local subArea = mapInfo.subArea

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
        local file = io.open(fileName, "w")
        file:write(json:encode(maps))
        file:close()
    end

    -- SubAreas
    for subArea, maps in pairs(subAreaMaps) do
        local fileName = mapDirectory .. "SubAreas\\" .. subArea .. ".json"
        local file = io.open(fileName, "w")
        file:write(json:encode(maps))
        file:close()
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

function getClosestUnexploredMap()
    local closestMapId = nil
    local minDistance = math.huge
    local currentPos = { x = visitedMaps[currentMapId].pos.x, y = visitedMaps[currentMapId].pos.y }

    for _, mapData in pairs(visitedMaps) do
        for _, dir in ipairs(directions) do
            if not mapData[dir].visited and not mapData[dir].isBlocked then
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

    return closestMapId
end

function cleanVisited()
    local cleanedData = {}
    for mapId, mapInfo in pairs(visitedMaps) do
        cleanedData[mapId] = {
            mapId = mapInfo.mapId,
            area = mapInfo.area,
            subArea = mapInfo.subArea,
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
