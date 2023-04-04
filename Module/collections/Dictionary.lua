local dictionary = {
    dependencies = { "list" }
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

function dictionary:init()
    self.data = {}
end

-- Ajouter une paire clé-valeur
function dictionary:add(key, value)
    if not self:containsKey(key) then
        self.data[key] = value
    end
    return self
end

-- Ajouter une paire clé-valeur
function dictionary:set(key, value)
    if self:containsKey(key) then
        self.data[key] = value
    end
    return self
end


-- Obtenir la valeur d'une clé
function dictionary:get(key)
    if self.logger then
    end
    return self.data[key]
end

-- Récupére toutes les clés associées à une valeur spécifique
function dictionary:getByValue(value)
    local keys = self.list()
    for key, val in pairs(self.data) do
        if val == value then
            keys:add(key)
        end
    end
    return keys
end

-- Recherche la première paire clé-valeur qui satisfait une condition donnée
function dictionary:find(predicate)
    for key, value in pairs(self.data) do
        if predicate(key, value) then
            return key, value
        end
    end
    return nil, nil
end

-- Recherche toutes les paires clé-valeur qui satisfont une condition donnée
function dictionary:findAll(predicate)
    local results = self.list()
    for key, value in pairs(self.data) do
        if predicate(key, value) then
            results:add({ key = key, value = value })
        end
    end
    return results
end

-- Obtenir la valeur la clé d'une valeur
function dictionary:getKey(value)
    for k, v in pairs(self.data) do
        if v == value then
            return k
        end
    end
    return nil
end

-- Supprimer une clé et sa valeur associée
function dictionary:remove(key)
    self.data[key] = nil
    return self
end

-- Vider le dictionnaire
function dictionary:clear()
    self.data = {}
    return self
end

-- Vérifier si une clé existe
function dictionary:containsKey(key)
    return self.data[key] ~= nil
end

-- Vérifier si une valeur existe
function dictionary:containsValue(value)
    for _, v in pairs(self.data) do
        if v == value then
            return true
        end
    end
    return false
end

-- Vérifier si une pairs clé/valeur existe
function dictionary:containsPair(key, value)
    return self.data[key] == value
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
    return self
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
        if self:containsKey(key) then
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
    return { key = random_key, item = self.data[random_key] }
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

-- Transformer les clés du dictionnaire en utilisant une fonction
function dictionary:mapKeys(func)
    local result = self.newInstance()
    for key, value in pairs(self.data) do
        local new_key = func(key)
        result:add(new_key, value)
    end
    return result
end

-- Transformer les valeurs du dictionnaire en utilisant une fonction
function dictionary:mapValues(func)
    local result = self.newInstance()
    for key, value in pairs(self.data) do
        local new_value = func(value)
        result:add(key, new_value)
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

-- Vérifie si au moins une paire clé-valeur satisfait une condition donnée
function dictionary:some(predicate)
    for key, value in pairs(self.data) do
        if predicate(key, value) then
            return true
        end
    end
    return false
end

-- Vérifie si toutes les paires clé-valeur satisfont une condition donnée
function dictionary:every(predicate)
    for key, value in pairs(self.data) do
        if not predicate(key, value) then
            return false
        end
    end
    return true
end

-- Compte le nombre de paires clé-valeur qui satisfont une condition donnée
function dictionary:count(predicate)
    local count = 0
    for key, value in pairs(self.data) do
        if predicate(key, value) then
            count = count + 1
        end
    end
    return count
end

-- Récupére le nombre de pairs clés-valeurs dans le dictionnaire
function dictionary:length()
    local l = 0
    for _ in pairs(self.data) do
        l = l + 1
    end
    return l
end

-- Copier le dictionnaire
function dictionary:copy()
    local copied_dict = self.newInstance()
    for key, value in pairs(self.data) do
        copied_dict:add(key, value)
    end
    return copied_dict
end

function dictionary:enumerate()
    local enumerated = {}
    for key, value in pairs(self.data) do
        enumerated[key] = value
    end
    return enumerated
end

-- Vérifier si le dictionnaire est vide
function dictionary:isEmpty()
    return self:length() ~= 0
end

-- Fusionner plusieurs dictionnaires
function dictionary:mergeMultiple(dictionaries)
    local result = self.newInstance()
    for _, dic in ipairs(dictionaries) do
        result:merge(dic)
    end
    return result
end

function dictionary.__pairs(v)
    local key, value
    return function()
        key, value = next(v.data, key)
        return key, value
    end
end

function dictionary.__ipairs(v)
    local function keysAsIndexIterator(dict, prevIdx)
        prevIdx = prevIdx + 1
        local key = dict.sortedKeys[prevIdx]

        if key then
            return prevIdx, dict.data[key]
        end
    end

    v.sortedKeys = {}
    for key in pairs(v.data) do
        table.insert(v.sortedKeys, key)
    end

    return keysAsIndexIterator, v, 0
end

function dictionary.__len(v)
    return v:length()
end

function dictionary.__eq(self, other)
    return self:equals(other)
end

function dictionary.__add(self, other)
    local result = self:copy()
    result:merge(other)
    return result
end

function dictionary.__sub(self, other)
    local result = self:copy()
    for key in pairs(other) do
        result:remove(key)
    end
    return result
end

return dictionary
