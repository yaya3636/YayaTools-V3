local moduleLoader = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\ModuleLoader.lua]])(1)
local dictionary = moduleLoader:load("dictionary")
local list = moduleLoader:load("list")
local class = moduleLoader:load("class")
local list3 = moduleLoader:load("list")
local wrong = moduleLoader:load("listt")
local logger = moduleLoader:load("logger")(1)
local linkedList = moduleLoader:load("linkedList")
local json = moduleLoader:load("Json")()
Packet = moduleLoader:load("PacketManager")
Monsters = moduleLoader:load("Monsters")()
Recipes = moduleLoader:load("Recipes")()

Areas = moduleLoader:load("Areas")
SubAreas = moduleLoader:load("SubAreas")

AStar = moduleLoader:load("AStar")


function GetSubAreaObject(subAreaId)
    local subArea = d2data:objectFromD2O("SubAreas", subAreaId).Fields
    if subArea then
        local ret = {}
        ret.mapIds = list:fromTable(subArea.mapIds)
        return ret
    end
    return nil
end

function GetAreaObject(areaId)
    local areas = dictionary()

    local d2 = d2data:allObjectsFromD2O("SubAreas")

    for _, v in pairs(d2) do
        if not areas:containsKey(v.Fields.areaId) then
            local l = list()
            l:add(v.Fields.id)
            areas:add(v.Fields.areaId, l)
        else
            local l = areas:get(v.Fields.areaId)
            l:add(v.Fields.id)
            areas:set(v.Fields.areaId, l)
        end
    end
    local area = d2data:objectFromD2O("Areas", areaId).Fields
    if area then
        local ret = {}
        ret.subAreas = areas:get(areaId)
        return ret
    end
    return nil
end

function GetAreaMapId(areaId)
    local ret = list()
    local area = GetAreaObject(areaId)
    for _, vSubAreaId in pairs(area.subAreas) do
        local subAreaMapId = GetSubAreaObject(vSubAreaId).mapIds
        for _, vMapId in pairs(subAreaMapId) do
            ret:add(vMapId)
        end
    end
    return ret
end

function afficheTableau(tab, indent, indent_char, separator, visited)
    if tab then
        indent = indent or 0
        indent_char = indent_char or "  "
        separator = separator or " : "
        visited = visited or {}
        local indentation = string.rep(indent_char, indent)

        visited[tab] = true

        for cle, valeur in pairs(tab) do
            if type(valeur) == "table" then
                logger:log(indentation .. tostring(cle) .. separator)
                if not visited[valeur] then
                    afficheTableau(valeur, indent + 1, indent_char, separator, visited)
                else
                    logger:log(indentation .. indent_char .. tostring(valeur) .. " [référence déjà visitée]")
                end
            else
                logger:log(indentation .. tostring(cle) .. separator .. tostring(valeur))
            end
            global:delay(200)
        end
    end
end

function move()
    -- local executionTime, result = MeasureExecutionTime(function() return Areas:getAllMapsByDFS() end)
    -- --logger:log(result)
    -- logger:log("Execution time: " .. executionTime .. " seconds")
    local listMap = SubAreas:getSubAreaMapsByDFS(97)
    local listMapAstar = list()
    for _, v in pairs(listMap) do
        listMapAstar:add(v.mapId)
    end
    --logger:log(listMapAstar)
    local astar = AStar(listMapAstar)

    for i = 1, 10 do
        local path = astar:findPath(189661705, 189531654)
        logger:log(path)
    end
    --local area = Areas:getAllMapsByDFS("Astrub")
    --logger:log(area)
    -- local area = SubAreas:getSubAreaMapsByDFS("Astrub")
    -- logger:log(area)
    --logger:log(SubAreas:getSubAreaMapsByDFS(200000))

    --logger:log(Recipes:getRecipesObject(159))


end

function bank()
    logger:log("Func bank")
end

function stopped()
    logger:log("Func stopped")
end

function MeasureExecutionTime(functionToExecute, ...)
    local startTime = os.clock()
    local results = {functionToExecute(...)}
    local endTime = os.clock()
    local executionTime = endTime - startTime

    return executionTime, unpack(results)
end
