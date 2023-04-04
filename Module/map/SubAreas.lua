local subAreas = {
    dependencies = { "list", "dictionary", "json" },
    singleton = true
}

function subAreas:init()
    self.pathSubAreas = global:getCurrentDirectory() .. [[\YayaToolsV3\Data\Maps\SubAreas]]
    self.nameToId = self.dictionary()
    local d2SubAreas = d2data:allObjectsFromD2O("SubAreas")

    for _, v in pairs(d2SubAreas) do
        self.nameToId:add(d2data:text(v.Fields.nameId), v.Fields.id)
    end

end



function subAreas:getSubAreaObjectById(subAreaId)
    local subArea = d2data:objectFromD2O("SubAreas", subAreaId)

    if subArea then
        subArea = subArea.Fields
        local ret = subArea
        ret.name = d2data:text(ret.nameId)
        ret.playlists = subArea.playlists.Fields
        ret.shape = nil
        --ret.npcs = nil
        ret.mapIds = self.list:fromTable(subArea.mapIds)
        ret.bounds = subArea.bounds.Fields
        ret.monsters = self.list:fromTable(subArea.monsters)
        ret.harvestables = self.list:fromTable(subArea.harvestables)
        return ret
    else
        self.logger:warning("SubArea not found: " .. tostring(subAreaId), "SubAreas")
    end
    return nil
end

function subAreas:getSubAreaIdByMapId(mapId)
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

function subAreas:getSubAreaObjectByName(name)
    local id = self.nameToId:get(name)
    local object = self:getSubAreaObjectById(id)
    return object
end

-- DFS

function subAreas:getSubAreaPathDFS(search)
    local pattern = "^%[" .. search .. "%]" -- Recherche l'ID
    if not string.find(search, "%d") then -- Si la recherche ne contient pas de chiffres, recherche le nom
        pattern = search .. "%.json$"
    end

    for _, valeur in ipairs(global:getAllFilesNameInDirectory(self.pathSubAreas, ".json")) do
        if type(valeur) == "string" and string.match(valeur, pattern) then
            return valeur
        end
    end

    return nil
end

function subAreas:loadSubAreaMapsDFS(path)
    if path then
        local file = io.open(self.pathSubAreas .. "\\" .. path, "r")
        local content = file:read("*all")
        file:close()
        return self.json:decode(content)
    end
    return nil
end

function subAreas:getSubAreaMapsByDFS(search)
    local path = self:getSubAreaPathDFS(search)
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

        local maps = self.dictionary()
        if subAreaDFS then
            for _, map in pairs(subAreaDFS) do
                maps:add(map.mapId ,sortMap(map))
            end
        else
            self.logger:warning("SubArea loading error " .. tostring(search), "SubAreas")
        end

        return maps
    else
        self.logger:warning("SubArea not found: " .. tostring(search), "SubAreas")
    end
end

return subAreas
