local moduleLoader = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\ModuleLoader.lua]])(1)
local dictionary = moduleLoader:load("dictionary")
local list = moduleLoader:load("list")
local logger = moduleLoader:load("logger")(1)
local json = moduleLoader:load("Json")()

-- Variables globales
local visitedMaps = {}
local visitedDirections = {}
local stack = {}
local moveCounter = 0
local lastMapId = nil
local lastDir = nil

function move()
    onMapChanged()
end

-- Fonction pour trouver un voisin non visité
function findUnvisitedNeighbor(mapId)
    local unvisitedDirs = {}
    for dir, visited in pairs(visitedDirections[mapId]) do
        if not visited then
            table.insert(unvisitedDirs, dir)
        end
    end

    if #unvisitedDirs == 0 then
        return nil
    end

    local dir = unvisitedDirs[math.random(#unvisitedDirs)]
    return {dir = dir}
end

-- Fonction à appeler à chaque changement de carte
function onMapChanged()
    local currentMapId = map:currentMapId()

    if not visitedMaps[currentMapId] then
        visitedMaps[currentMapId] = {
            left = nil,
            right = nil,
            top = nil,
            bottom = nil
        }

        visitedDirections[currentMapId] = {
            left = false,
            right = false,
            top = false,
            bottom = false
        }
        table.insert(stack, currentMapId)
    end

    if lastMapId and lastDir then
        visitedMaps[lastMapId][lastDir] = currentMapId
    end

    local nextDirInfo = findUnvisitedNeighbor(currentMapId)

    if nextDirInfo then
        visitedDirections[currentMapId][nextDirInfo.dir] = true

        if not map:move(nextDirInfo.dir) then
            logger:log(
                "Impossible de se déplacer dans la direction : " .. nextDirInfo.dir,
                "BFS",
                3
            )
            onMapChanged()
        else
            lastMapId = currentMapId
            lastDir = nextDirInfo.dir
            moveCounter = moveCounter + 1
            if moveCounter % 15 == 0 then
                -- Exporter les cartes visitées et réinitialiser le compteur
                exportVisitedMaps()
                moveCounter = 0
            end
        end
    else
        if #stack > 0 then
            table.remove(stack)  -- Retirer l'élément actuel de la pile

            if #stack > 0 then
                lastMapId = nil
                lastDir = nil
                move()
            end
        else
            logger:log("Toutes les cartes ont été explorées.", "BFS", 2)
        end
    end
end

function loadAreaMapIds()
    local areaFiles = global:getAllFilesNameInDirectory(mapDirectory .. "Areas", ".json")-- Utilisez votre fonction existante pour obtenir la liste des fichiers area

    for _, areaFile in ipairs(areaFiles) do
        local file = io.open(mapDirectory .. "Areas\\" .. areaFile, "r")
        if file then
            local fileContent = file:read("*all")
            file:close()
            local areaMaps = json:decode(fileContent)

            for _, mapInfo in ipairs(areaMaps) do
                if not visitedMaps[mapInfo.mapId] then
                    visitedMaps[mapInfo.mapId] = mapInfo
                end
            end
        end
    end
end

-- Fonction pour exporter les cartes visitées en fichiers JSON
function exportVisitedMaps()
    local areaMaps = {}
    local subAreaMaps = {}

    for _, mapInfo in pairs(visitedMaps) do
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

    for area, maps in pairs(areaMaps) do
        local fileName = mapDirectory .. "Areas\\" .. area .. ".json"
        local existingData = {}
        if io.open(fileName, "r") then
            local file = io.open(fileName, "r")
            local fileContent = file:read("*all")
            existingData = json:decode(fileContent)
            file:close()
        end

        for _, mapInfo in ipairs(maps) do
            if not contains(existingData, mapInfo.mapId) then
                table.insert(existingData, mapInfo)
            end
        end

        local file = io.open(fileName, "w")
        file:write(json:encode(existingData))
        file:close()
    end

    for subArea, maps in pairs(subAreaMaps) do
        local fileName =  mapDirectory .. "SubAreas\\" .. subArea .. ".json"
        local existingData = {}
        if io.open(fileName, "r") then
            local file = io.open(fileName, "r")
            local fileContent = file:read("*all")
            existingData = json:decode(fileContent)
            file:close()
        end

        for _, mapInfo in ipairs(maps) do
            if not contains(existingData, mapInfo.mapId) then
                table.insert(existingData, mapInfo)
            end
        end

        local file = io.open(fileName, "w")
        file:write(json:encode(existingData))
        file:close()
    end
end

function contains(table, element)
    for _, value in ipairs(table) do
        if value == element then
            return true
        end
    end
    return false
end