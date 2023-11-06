local Logger = {
    dependencies = { "dictionary", "list" }
}

function Logger:init(level, showTimestamp)
    self.levels = self.dictionary()
    self.levels:add("DEBUG", 1)
    self.levels:add("INFO", 2)
    self.levels:add("WARNING", 3)
    self.levels:add("ERROR", 4)

    self.colors = self.dictionary()
    self.colors:add("DEBUG", "#975df5")
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
    header = header or ""
    if message == nil then
        self:log("Le message est nil", "Logger;" .. header, level)
    elseif type(message) == "table" then
        self:log("Le message et une table, affichage de la table...", "Logger;" .. header, 2)
        self:printTable(message)
    elseif type(message) == "string" or type(message) == "number" or type(message) == "boolean" then
        if message == nil then
            message = "nil"
        end
        message = tostring(message)
        level = level or self.levels:get("DEBUG")

        if level >= self.level then
            local levelName = self.levels:getKey(level) or "DEBUG"
            local color = self.colors:get(levelName) or self.colors:get("DEBUG")
            local headers = {}

            if header then
                headers = self:splitHeaders(header)
            end

            for _, h in ipairs(headers) do
                if not self:isHeaderFiltered(h:upper()) then
                    color = self.colors:get(h:upper()) or self.colors:get(levelName)
                    message = "[" .. h .. "] " .. message
                end
            end

            local timestamp = self.showTimestamp and self:getTimestamp() or ""
            global:printColor(color, timestamp .. "[" .. levelName .. "] " .. message)

            if level == self.levels:get("ERROR") then
                global:finishScript()
            end
        end
    end
end

function Logger:splitHeaders(headerString)
    local headers = self.list()
    for header in string.gmatch(headerString, '([^;]+)') do
        headers:add(header)
    end
    return headers:reverse()
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

function Logger:printTable(tab, ignoreKeys, indent, indent_char, separator, visited, header)
    if tab then
        indent = indent or 0
        ignoreKeys = ignoreKeys or ""
        indent_char = indent_char or "  "
        separator = separator or " : "
        visited = visited or {}
        local indentation = string.rep(indent_char, indent)
        visited[tab] = true

        -- Transform the ignoreKeys string into a table for easier lookup
        local keysToIgnore = {}
        for key in string.gmatch(ignoreKeys, '([^;]+)') do
            keysToIgnore[key] = true
        end

        for cle, valeur in pairs(tab) do
            -- Skip if key is in the keys to ignore
            if not keysToIgnore[cle] then
                local currentHeader = header or ""
                if type(valeur) == "table" then
                    if valeur.className then
                        currentHeader = "ValueOf" .. valeur.className
                    else
                        currentHeader = tab.className or currentHeader
                    end
                    self:log(indentation .. tostring(cle) .. separator, currentHeader)
                    if not visited[valeur] then
                        self:printTable(valeur, ignoreKeys, indent + 1, indent_char, separator, visited, currentHeader)
                    else
                        if valeur.className then
                            valeur = "Class " .. valeur.className
                        end
                        self:log(indentation .. indent_char .. tostring(valeur) .. " [référence déjà visitée]", currentHeader)
                    end
                else
                    if tab.className then
                        currentHeader = "ValueOf" .. tab.className
                    end
                    self:log(indentation .. tostring(cle) .. separator .. tostring(valeur), currentHeader)
                end
            end
        end
    end
end



-- function Logger:printTable(tab, indent, indent_char, separator, visited, header)
--     if tab and type(tab) == "table" then
--         indent = indent or 0
--         indent_char = indent_char or "  "
--         separator = separator or " : "
--         visited = visited or {}
--         local indentation = string.rep(indent_char, indent)
--         visited[tab] = true

--         for cle, valeur in pairs(tab) do
--             local currentHeader = header or ""
--             if type(valeur) == "table" then
--                 currentHeader = valeur.className or currentHeader
--                 self:log(indentation .. tostring(cle) .. separator, currentHeader)
--                 if not visited[valeur] then
--                     self:printTable(valeur, indent + 1, indent_char, separator, visited, currentHeader)
--                 else
--                     if valeur.className then
--                         valeur = "Class " .. valeur.className
--                     end
--                     self:log(indentation .. indent_char .. tostring(valeur) .. " [référence déjà visitée]", currentHeader)
--                 end
--             else
--                 if tab.className then
--                     currentHeader = "ValueOf" .. tab.className
--                 end
--                 self:log(indentation .. tostring(cle) .. separator .. tostring(valeur), currentHeader)
--             end
--         end
--     else
--         self:warning("Le message n'est pas une table", "Logger")
--     end
-- end

return Logger
