local Logger = {
    dependencies = {"dictionary", "list"}
}

function Logger:init(level, showTimestamp)
    self.levels = self.dictionary()
    self.levels:add("DEBUG", 1)
    self.levels:add("INFO", 2)
    self.levels:add("WARNING", 3)
    self.levels:add("ERROR", 4)

    self.colors = self.dictionary()
    self.colors:add("DEBUG", "0x00FF00")
    self.colors:add("INFO", "0x00FFFF")
    self.colors:add("WARNING", "0xFFFF00")
    self.colors:add("ERROR", "0xFF0000")


    self.level = level or self.levels:get("DEBUG")
    self.showTimestamp = showTimestamp or false
    self.filteredHeaders = self.dictionary()
end

function Logger:getTimestamp()
    return os.date("[%Y-%m-%d %X] ")
end

function Logger:log(message, header, level)
    message = tostring(message)
    level = level or self.levels:get("DEBUG")
    if level >= self.level then
        local levelName = self.levels:getKey(level) or "DEBUG"
        local color = self.colors:get(levelName) or self.colors:get("DEBUG")
        if header and not self:isHeaderFiltered(header:upper()) then
            color = self.colors:get(header:upper()) or self.colors:get(levelName)
            message = "[" .. header .. "] " .. message
        end
        local timestamp = self.showTimestamp and self:getTimestamp() or ""
        global:printColor(color, timestamp .. "[" .. levelName .. "] " .. message)
        if level == self.levels:get("ERROR") then
            global:finishScript()
        end
    end
end

function Logger:debug(message, header)
    self:log(message, header, self.levels:get("DEBUG"))
end

function Logger:info(message, header)
    self:log(message, header, self.levels:get("INFO"))
end

function Logger:warning(message, header)
    self:log(message, header, self.levels:get("WARNING"))
end

function Logger:error(message, header)
    self:log(message, header, self.levels:get("ERROR"))
end

function Logger:addHeaderColor(header, color)
    self.colors:add(header:upper(), color)
    self:log("Couleur ajoutée pour l'en-tête " .. header, "Logger", 2)
end

function Logger:filterHeader(header, filter)
    if filter then
        self.filteredHeaders:add(header:upper())
        self:info("En-tête filtré : " .. header, "Logger")
    else
        self.filteredHeaders:remove(header:upper())
        self:info("En-tête non filtré : " .. header, "Logger")
    end
end

function Logger:setLevel(level)

    for k, v in pairs(self.levels) do
        if v == level then
            self:info("Niveau de log défini sur : " .. k, "Logger")
            self.level = v
            return
        end
    end
    self:warning("Niveau de log invalide : " .. level, "Logger")

end

function Logger:isHeaderFiltered(header)
    return self.filteredHeaders:get(header:upper())
end

function Logger:listFilteredHeaders()
    return self.filteredHeaders:getKeys()
end

return Logger
