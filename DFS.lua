local moduleLoader = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\ModuleLoader.lua]])(1)
local logger = moduleLoader:load("logger")(1)
local json = moduleLoader:load("Json")()

local mapDirectory = global:getCurrentDirectory() .. [[\YayaToolsV3\Data\Maps\]]

local directions = { "left", "right", "top", "bottom" }
local visitedMaps = {}
local stack = {}
local currentState = "explore"
local lastMapId = 0
local lastDirection = ""

function move()
    onMapChanged()
end

function onMapChanged()
    logger:log("currentState = " .. currentState)
    local currentMapId = map:currentMapId()

    if not visitedMaps[currentMapId] then
        visitedMaps[currentMapId] = {}
        visitedMaps[currentMapId].area = map:currentArea()
        visitedMaps[currentMapId].subArea = map:currentSubArea()
        for _, dir in ipairs(directions) do
            visitedMaps[currentMapId][dir] = {
                visited = false,
                isBlocked = false
            }
        end
    end

    if currentState == "explore" then
        if lastMapId ~= 0 then
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
                lastMapId = 0
                visitedMaps[currentMapId][nextDirection].isBlocked = true
                table.remove(stack, #stack)
                onMapChanged()
            end
        else
            currentState = "backtrack"
            onMapChanged()
        end
    elseif currentState == "backtrack" then
        if #stack > 0 then
            local currentStackItem = stack[#stack]
            local lastMap = currentStackItem.mapId
            local oppositeDirection = getOppositeDirection(currentStackItem.lastDirection)
            local removed = table.remove(stack)
            currentState = "explore"

            if not map:changeMap(oppositeDirection) then
                visitedMaps[lastMap][oppositeDirection].isBlocked = true
                table.insert(stack, removed)
                currentState = "backtrack"
                onMapChanged()
            end
        else
            print("Exploration terminée. Toutes les cartes ont été explorées.")
            currentState = "finished"
        end
    elseif currentState == "finished" then

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

function stopped()
    logger:printTable(visitedMaps)
end
