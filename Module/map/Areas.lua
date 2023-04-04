local areas = {
    dependencies = { "list", "dictionary", "json" },
    singleton = true
}

function areas:init()
    self.pathAreas = global:getCurrentDirectory() .. [[\YayaToolsV3\Data\Maps\Areas]]
    self.nameToId = self.dictionary()
    self.subAreaInArea = self.dictionary()

    local d2Area = d2data:allObjectsFromD2O("Areas")
    local d2SubArea = d2data:allObjectsFromD2O("SubAreas")


    for _, v in pairs(d2Area) do
        self.nameToId:add(d2data:text(v.Fields.nameId), v.Fields.id)
    end

    for _, v in pairs(d2SubArea) do
        if not self.subAreaInArea:containsKey(v.Fields.areaId) then
            local l = self.list()
            l:add(v.Fields.id)
            self.subAreaInArea:add(v.Fields.areaId, l)
        else
            local l = self.subAreaInArea:get(v.Fields.areaId)
            l:add(v.Fields.id)
            self.subAreaInArea:set(v.Fields.areaId, l)
        end
    end
end

function areas:getAreaObjectById(areaId)
    local area = d2data:objectFromD2O("Areas", areaId)
    if area then
        area = area.Fields
        local ret = area
        ret.name = d2data:text(ret.nameId)
        ret.bounds = area.bounds.Fields
        ret.subAreas = self.subAreaInArea:get(areaId)
        return ret
    else
        self.logger:warning("Area not found: " .. tostring(areaId), "Areas")
    end
    return nil
end

function areas:getAreaObjectByName(name)
    local id = self.nameToId:get(name)
    local object = self:getAreaObjectById(id)
    return object
end

function areas:getAreaIdByMapId(mapId)
    local id
    for _, subArea in pairs(d2data:allObjectsFromD2O("SubAreas")) do
        for _, map in pairs(subArea.Fields.mapIds) do
            if map == mapId then
                return subArea.Fields.areaId
            end
        end
    end
    return id
end

-- DFS

function areas:getAreaPathDFS(search)
    local pattern = "^%[" .. search .. "%]" -- Recherche l'ID
    if not string.find(search, "%d") then -- Si la recherche ne contient pas de chiffres, recherche le nom
        pattern = search .. "%.json$"
    end

    for _, valeur in ipairs(global:getAllFilesNameInDirectory(self.pathAreas, ".json")) do
        if type(valeur) == "string" and string.match(valeur, pattern) then
            return valeur
        end
    end

    return nil
end

function areas:loadSubAreaMapsDFS(path)
    if path then
        local file = io.open(self.pathAreas .. "\\" .. path, "r")
        local content = file:read("*all")
        file:close()
        return self.json:decode(content)
    end
    return nil
end

function areas:getAreaMapsByDFS(search)
    local path = self:getAreaPathDFS(search)
    --self.logger:log(path, "SubAreas")
    local function sortMap(map)
        local ret = {}
        ret.mapId = map.mapId
        ret.area = map.area
        ret.subArea = map.subArea
        ret.areaId = map.areaId
        ret.subAreaId = map.subAreaId
        ret.neighbours = self.dictionary()
        for _, dir in pairs({"left", "right", "top", "bottom"}) do
            if map[dir] ~= nil then
                ret.neighbours:add(dir, map[dir].mapId)
            end
        end
        return ret
    end
    if path then
        local subAreaDFS = self:loadSubAreaMapsDFS(path)
        --self.logger:log(subAreaDFS, "SubAreas")

        local maps = self.dictionary()
        if subAreaDFS then
            for _, map in pairs(subAreaDFS) do
                maps:add(tostring(map.mapId),sortMap(map))
            end
        else
            self.logger:warning("SubArea loading error " .. tostring(search), "SubAreas")
        end

        return maps
    else
        self.logger:warning("SubArea not found: " .. tostring(search), "SubAreas")
    end
end

function areas:getAllMapsByDFS()
    local allAreaPath = global:getAllFilesNameInDirectory(self.pathAreas, ".json")
    local allMaps = self.dictionary()
    for _, path in pairs(allAreaPath) do
        --self.logger:log("Test")
        local maps = self:getAreaMapsByDFS(string.match(path, "^%[(%d+)%]"))
        for _, map in pairs(maps) do
            allMaps:add(tostring(map.mapId), map)
        end
    end
    return allMaps
end

return areas