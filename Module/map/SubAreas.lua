local subAreas = {
    dependencies = { "list", "dictionary" }
}

function subAreas:init()
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

return subAreas
