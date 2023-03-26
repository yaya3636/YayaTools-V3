local moduleLoader = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\ModuleLoader.lua]])(1)
local dictionary = moduleLoader:load("dictionary")
local list = moduleLoader:load("list")
local logger = moduleLoader:load("logger")(1)
local json = moduleLoader:load("Json")()
local packet = moduleLoader:load("packetManager")()
-- Variables globales
local visitedMaps = {}
local stack = {}
local moveCounter = 0
local mapDirectory = global:getCurrentDirectory() .. [[\YayaToolsV3\Data\Maps\]]
local started = false
function log()
    logger:log("test")
end

--packet:subscribePacket("ChatServerMessage", log)

function test()

end

function test2()

end

logger:printTable(debug)

function move()
    -- if not started then
    --     started = true
    --     logger:warning("Chargement des maps déja visité", "Json")
    --     loadAreaMapIds()
    --     logger:printTable(visitedMaps)
    -- end
    -- onMapChanged()
    local isChangedMap = map:changeMap("right")
    logger:log(isChangedMap)
end

function messagesRegistering()
    packet:subscribePacket("GameMapMovementRequestMessage", log)
    packet:subscribePacket("ChatServerMessage", log)

end

function stopped()
    logger:warning("Trajet arreter, exportation des maps au format Json", "JSON")
    exportVisitedMaps()
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

-- Fonction pour trouver un voisin non visité
function findUnvisitedNeighbor(mapId)
    for dir, neighborMapId in pairs(visitedMaps[mapId].neighbors) do
        if not visitedMaps[neighborMapId] then
            return {mapId = neighborMapId, dir = dir}
        end
    end
    return nil
end

-- Fonction à appeler à chaque changement de carte
function onMapChanged()
    local currentMapId = map:currentMapId()
    if not visitedMaps[currentMapId] then
        moveCounter = moveCounter + 1
        visitedMaps[currentMapId] = getMapInfo()
        table.insert(stack, currentMapId)
        if moveCounter == 15 then
            moveCounter = 0
            logger:warning("Exportation des maps au format Json", "JSON")
            exportVisitedMaps()
        end
    end

    local nextMapId = findUnvisitedNeighbor(currentMapId)

    if not nextMapId and #stack > 0 then
        while not nextMapId and #stack > 0 do
            table.remove(stack)  -- Retirer l'élément actuel de la pile
            if #stack > 0 then
                currentMapId = stack[#stack]  -- Revenir à la dernière position enregistrée dans la pile
                nextMapId = findUnvisitedNeighbor(currentMapId)
            end
        end
    end

    if nextMapId then
        if not map:moveToward(nextMapId.mapId) then -- Déplacer le personnage vers la prochaine carte non visitée
            logger:log("Impossible de se déplacer vers la mapId : (" .. nextMapId.mapId .. ") direction : " .. nextMapId.dir, "BFS", 3)

            visitedMaps[currentMapId].neighbors[nextMapId.dir] = nil
            onMapChanged()
        end
    else
        logger:log("Toutes les cartes ont été explorées.", "BFS", 2)
    end
end

function getMapInfo()
    local currentMapId = map:currentMapId()
    local dir = {"left", "right", "top", "bottom"}
    local neighborId = {}
    for k, v in pairs(dir) do
        local mapId = map:neighbourId(v)
        if mapId ~= 0 then
            neighborId[v] = mapId
        end
    end
    return { mapId = currentMapId, neighbors = neighborId, area = map:currentArea(), subArea = map:currentSubArea()}
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

function compareFunctions(f1, f2)
    -- récupère les informations sur les fonctions
    local info1 = debug.getinfo(f1, "S")
    local info2 = debug.getinfo(f2, "S")
  
    -- compare le nombre de lignes de code
    if info1.linedefined ~= info2.linedefined or info1.lastlinedefined ~= info2.lastlinedefined then
      return false
    end
  
    -- compare les instructions ligne par ligne
    for i=info1.linedefined,info1.lastlinedefined do
      local s1 = debug.getinfo(f1, "Sl", i)
      local s2 = debug.getinfo(f2, "Sl", i)
      if s1.source ~= s2.source or s1.currentline ~= s2.currentline or s1.what ~= s2.what then
        return false
      end
    end
  
    -- les fonctions ont la même structure de code
    return true
  end