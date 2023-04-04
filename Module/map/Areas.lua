local areas = {
    dependencies = { "list", "dictionary" }
}

function areas:init()
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

return areas