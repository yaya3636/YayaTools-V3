-- local class = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\Class.lua]])
-- local list = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\list\List.lua]])

local dictionary = {
    dependencies = {"list"}
}

-- Créer un dictionnaire à partir d'une table en utilisant les indices comme clés
function dictionary:fromTableIndices(tbl)
    local dict = self.newInstance()
    for index, value in ipairs(tbl) do
        dict:add(index, value)
    end
    return dict
end

function dictionary:fromTable(tbl)
    local dict = self.newInstance()
    for key, value in pairs(tbl) do
        dict:add(key, value)
    end
    return dict
end

-- Créer un dictionnaire à partir d'une table en utilisant les éléments comme clés et leurs occurrences comme valeurs
function dictionary:fromTableItems(tbl)
    local dict = self.newInstance()
    for _, value in ipairs(tbl) do
        local count = dict:get(value) or 0
        dict:add(value, count + 1)
    end
    return dict
end



--class("Dictionary", {
--     data = {}
-- })

function dictionary:init()
    if self.logger then
        self.logger = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\utils\Logger.lua]])(self.loggerLevel)
    end

    self.data = {}
end

-- Ajouter une paire clé-valeur
function dictionary:add(key, value)
    if self.logger then
        self.logger:log("La paire clef/valeur [ " .. tostring(key) .. " | " .. tostring(value) .. " ] a été ajouté au dictionnaire", "Dictionary")
    end
    self.data[key] = value
end

-- Obtenir la valeur d'une clé
function dictionary:get(key)
    if self.logger then
        if self.data[key] == nil then
            self.logger:log("La clef [ " .. tostring(key) .. " ] n'éxiste pas. (get)", "Dictionary", 3)
        end
    end
    return self.data[key]
end

-- Obtenir la valeur la clé d'une valeur
function dictionary:getKey(value)
    for k, v in pairs(self.data) do
        if v == value then
            return k
        end
    end
    if self.logger then
        self.logger:log("La valeur [ " .. tostring(value) .. " ] n'a pas été trouvé. (getKey)", "Dictionary", 3)
    end
    return nil
end

-- Supprimer une clé et sa valeur associée
function dictionary:remove(key)
    if self.logger then
        if self.data[key] == nil then
            self.logger:log("La clef [ " .. tostring(key) .. " ] n'éxiste pas. (Remove)", "Dictionary", 3)
        end
    end
    self.data[key] = nil
end

-- Vider le dictionnaire
function dictionary:clear()
    self.data = {}
end

-- Vérifier si une clé existe
function dictionary:contains(key)
    return self.data[key] ~= nil
end

-- Obtenir la taille du dictionnaire
function dictionary:size()
    local count = 0
    for _ in pairs(self.data) do
        count = count + 1
    end
    return count
end

-- Fusionner deux dictionnaires
function dictionary:merge(other)
    for key, value in pairs(other.data) do
        self:add(key, value)
    end
end

-- Récupérer toutes les clés sous forme de tableau
function dictionary:getKeys()
    local keys = {}
    for key in pairs(self.data) do
        table.insert(keys, key)
    end
    return self.list:fromTable(keys)
end

-- Récupérer toutes les valeurs sous forme de tableau
function dictionary:getValues()
    local values = {}
    for _, value in pairs(self.data) do
        table.insert(values, value)
    end
    return self.list:fromTable(values)
end

-- Appliquer une fonction à chaque paire clé-valeur du dictionnaire
function dictionary:forEach(func)
    for key, value in pairs(self.data) do
        func(key, value)
    end
end

-- Récupérer un sous-ensemble du dictionnaire en fonction des clés
function dictionary:subset(keys)
    local result = self.newInstance()
    for _, key in ipairs(keys) do
        if self:contains(key) then
            result:add(key, self:get(key))
        end
    end
    return result
end

-- Filtrer les éléments du dictionnaire en fonction d'une fonction de condition
function dictionary:filter(condition)
    local result = self.newInstance()
    for key, value in pairs(self.data) do
        if condition(key, value) then
            result:add(key, value)
        end
    end
    return result
end

-- Inverser les clés et les valeurs du dictionnaire
function dictionary:invert()
    local result = self.newInstance()
    for key, value in pairs(self.data) do
        result:add(value, key)
    end
    return result
end

-- Vérifier si deux dictionnaires sont égaux
function dictionary:equals(other)
    if self:size() ~= other:size() then
        return false
    end

    for key, value in pairs(self.data) do
        if other:get(key) ~= value then
            return false
        end
    end

    return true
end

-- Récupérer un élément aléatoire du dictionnaire
function dictionary:randomItem()
    local keys = self:getKeys()
    if #keys == 0 then
        return nil, nil
    end
    local random_key = keys[global:random(1, #keys)]
    return {key = random_key, item = self.data[random_key]}
end

-- Transformer les clés et les valeurs du dictionnaire en utilisant une fonction
function dictionary:map(func)
    local result = self.newInstance()
    for key, value in pairs(self.data) do
        local new_key, new_value = func(key, value)
        result:add(new_key, new_value)
    end
    return result
end

-- Compter les occurrences de valeurs dans le dictionnaire
function dictionary:valueCount()
    local counts = self.newInstance()
    for _, value in pairs(self.data) do
        local count = counts:get(value) or 0
        counts:add(value, count + 1)
    end
    return counts
end

-- Sélectionner les n premiers éléments du dictionnaire
function dictionary:nFirstItems(n)
    local result = self.newInstance()
    local count = 0
    for key, value in pairs(self.data) do
        if count < n then
            result:add(key, value)
            count = count + 1
        else
            break
        end
    end
    return result
end

-- Sélectionner les n derniers éléments du dictionnaire
function dictionary:nLastItems(n)
    local result = self.newInstance()
    local keys = self:getKeys()
    local count = 0
    for i = #keys, 1, -1 do
        if count < n then
            local key = keys[i]
            result:add(key, self:get(key))
            count = count + 1
        else
            break
        end
    end
    return result
end

-- Copier le dictionnaire
function dictionary:copy()
    local copied_dict = self.newInstance()
    for key, value in pairs(self.data) do
        copied_dict:add(key, value)
    end
    return copied_dict
end

-- Vérifier si le dictionnaire est vide
function dictionary:isEmpty()
    return next(self.data) == nil
end

-- Fusionner plusieurs dictionnaires
function dictionary:mergeMultipl(dictionaries)
    local result = self.newInstance()
    for _, dic in ipairs(dictionaries) do
        result:merge(dic)
    end
    return result
end


return dictionary