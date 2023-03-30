local moduleLoader = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\ModuleLoader.lua]])(1)
local logger = moduleLoader:load("logger")(1)
local json = moduleLoader:load("Json")()

local mapDirectory = global:getCurrentDirectory() .. [[\YayaToolsV3\Data\Maps\]]

local directions = { "left", "right", "top", "bottom" }
local visitedMaps = {}
local stack = {}
local currentState = "explore"
local countMove = 0
local lastMapId = "0"
local lastDirection = ""

local file = io.open(mapDirectory .. "visitedMaps.json", "r")

logger:log("Récupération des maps exploré", "DFS", 2)

if file then
    local fileContent = file:read("*all")
    file:close()
    visitedMaps = json:decode(fileContent)
end

logger:log("Récupération des maps exploré terminée", "DFS", 2)

for k, v in pairs(visitedMaps) do
    for _, dir in pairs(directions) do
        if not v[dir].visited and not v[dir].isBlocked then
            table.insert(stack, { mapId = k, lastDirection = ""})
            goto continue
        end
    end

end

::continue::

function move()
    onMapChanged()
end

function stopped()
    exportVisitedMaps()
end

function onMapChanged()
    logger:log("currentState = " .. currentState)
    local currentMapId = tostring(map:currentMapId())
    local currentMapPos = { x = map:getX(tonumber(currentMapId)), y = map:getY(tonumber(currentMapId)) }
    countMove = countMove + 1
    if countMove >= 15 then
        countMove = 0
        exportVisitedMaps()
    end

    if not visitedMaps[currentMapId] then
        visitedMaps[currentMapId] = {}
        visitedMaps[currentMapId].mapId = currentMapId
        visitedMaps[currentMapId].area = map:currentArea()
        visitedMaps[currentMapId].subArea = map:currentSubArea()
        visitedMaps[currentMapId].pos = currentMapPos
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

        for visitedMapId, visitedMapData in pairs(visitedMaps) do
            if visitedMapData.pos.x == adjacentPosX and visitedMapData.pos.y == adjacentPosY then
                logger:log("Adjacent mapId déterminé | mapId : " ..
                    currentMapId .. ", direction : " .. dir .. ", toMapId : " .. visitedMapId)
                visitedMaps[currentMapId][dir].mapId = visitedMapId
                visitedMaps[currentMapId][dir].visited = true
                break
            end
        end
    end


    if currentState == "explore" then

        if lastMapId ~= "0" then
            visitedMaps[lastMapId][lastDirection].mapId = currentMapId
        end

        local nextDirection = nil
        for i, dir in ipairs(directions) do
            if not visitedMaps[currentMapId][dir].visited and not visitedMaps[currentMapId][dir].isBlocked then
                nextDirection = dir
                break
            end
        end

        if nextDirection then
            currentState = "explore"
            visitedMaps[currentMapId][nextDirection].visited = true
            table.insert(stack, { mapId = currentMapId, lastDirection = nextDirection })

            lastMapId = currentMapId
            lastDirection = nextDirection

            if not map:changeMap(nextDirection) then
                lastMapId = "0"
                visitedMaps[currentMapId][nextDirection].isBlocked = true
                table.remove(stack, #stack)
                onMapChanged()
            end
        else
            currentState = "backtrack"
            onMapChanged()
        end
    elseif currentState == "backtrack" then
        local targetMapId = nil

        for i = #stack, 1, -1 do
            local stackItem = stack[i]
            local mapId = stackItem.mapId
            local unexploredDirection = false

            for _, dir in ipairs(directions) do
                if not visitedMaps[mapId][dir].visited and not visitedMaps[mapId][dir].isBlocked then
                    unexploredDirection = true
                    break
                end
            end

            if unexploredDirection then
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
                stack = {unpack(stack, 1, targetIndex)}
            end
            onMapChanged()
        end

        if targetMapId then
            map:moveToward(tonumber(targetMapId))
        else
            logger:log("Exploration terminée. Toutes les cartes ont été explorées.")
            currentState = "finished"
        end
    elseif currentState == "finished" then
    end
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