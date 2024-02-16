Json = {}

-- Fonction auxiliaire pour retirer les espaces au début de la chaîne
function Json:trimStart(str)
    return str:match("^%s*(.*)")
end

function Json:escapeString(s)
    local escapes = {
        ['"'] = '\\"',
        ['\\'] = '\\\\',
        ['/'] = '\\/',
        ['\b'] = '\\b',
        ['\f'] = '\\f',
        ['\n'] = '\\n',
        ['\r'] = '\\r',
        ['\t'] = '\\t'
    }
    return s:gsub('[\\"/bfnrt]', escapes):gsub('[\x00-\x1F]', function(c)
        return string.format("\\u%04X", c:byte())
    end)
end

-- Parse une valeur JSON
function Json:parseValue(s)
    s = self:trimStart(s)
    if s:sub(1, 1) == "{" then
        return self:parseObject(s)
    elseif s:sub(1, 1) == "[" then
        return self:parseArray(s)
    elseif s:sub(1, 1) == '"' then
        return self:parseString(s)
    elseif tonumber(s:sub(1, 1)) or s:sub(1, 1) == "-" then
        return self:parseNumber(s)
    elseif s:sub(1, 4) == "true" then
        return true, s:sub(5)
    elseif s:sub(1, 5) == "false" then
        return false, s:sub(6)
    elseif s:sub(1, 4) == "null" then
        return nil, s:sub(5)
    else
        self.logger:error("Valeur JSON invalide.", "Json")
    end
end

-- Parse un nombre
function Json:parseNumber(s)
    local numberString = s:match("^-?%d+%.?%d*[eE]?[+-]?%d*")
    if not numberString then self.logger:error("Format de nombre invalide.", "Json") end
    s = s:sub(numberString:len() + 1)
    return tonumber(numberString), self:trimStart(s)
end

-- Parse une chaîne de caractères
function Json:parseString(s)
    s = s:sub(2) -- Supprime le guillemet de début
    local endPos, startEscape
    local str = ""
    repeat
        endPos, startEscape = s:find('"', startEscape and startEscape + 1 or 1, true)
        if endPos and s:sub(endPos - 1, endPos - 1) == '\\' then
            str = str .. s:sub(1, endPos)
            startEscape = endPos
        end
    until endPos == nil or (endPos and s:sub(endPos - 1, endPos - 1) ~= '\\')
    if not endPos then self.logger:error("Fermeture de chaîne de caractères manquante.", "Json") end
    str = str .. s:sub(1, endPos - 1)
    str = str:gsub('\\"', '"'):gsub('\\\\', '\\') -- Gère les caractères échappés
    return str, self:trimStart(s:sub(endPos + 1))
end

-- Parse un tableau
function Json:parseArray(s)
    s = s:sub(2) -- Retire le crochet ouvrant
    local arr = {}
    s = self:trimStart(s)
    while s:sub(1, 1) ~= "]" do
        local value
        value, s = self:parseValue(s)
        arr[#arr + 1] = value
        s = self:trimStart(s)
        if s:sub(1, 1) == "," then
            s = self:trimStart(s:sub(2))
        end
    end
    return arr, self:trimStart(s:sub(2))
end

-- Parse un objet
function Json:parseObject(s)
    s = s:sub(2) -- Retire l'accolade ouvrante
    local obj = {}
    s = self:trimStart(s)
    while s:sub(1, 1) ~= "}" do
        local key, value
        key, s = self:parseString(s)
        s = self:trimStart(s:sub(2)) -- Retire le deux-points
        value, s = self:parseValue(s)
        obj[key] = value
        s = self:trimStart(s)
        if s:sub(1, 1) == "," then
            s = s:sub(2)
        end
        s = self:trimStart(s)
    end
    return obj, self:trimStart(s:sub(2))
end

-- Fonction principale de parsing
function Json:decode(input)
    local result, rest = self:parseValue(input)
    if self:trimStart(rest) ~= "" then
        self.logger:warning("Données JSON supplémentaires détectées après l'analyse.")
    end
    return result
end

function Json:encode(value, indent, level)
    indent = indent or ""
    level = level or 0
    local pad = indent ~= "" and string.rep(indent, level) or ""
    local padInner = indent ~= "" and string.rep(indent, level + 1) or ""

    if type(value) == "table" then
        local items, isArray = {}, true
        local maxIndex = 0
        for k, v in pairs(value) do
            if type(k) == "number" then
                maxIndex = math.max(maxIndex, k)
            else
                isArray = false
                break
            end
        end
        isArray = isArray and maxIndex == #value

        for k, v in pairs(value) do
            local encodedValue = self:encode(v, indent, level + 1)
            if isArray then
                table.insert(items, encodedValue)
            else
                table.insert(items, '"' .. self:escapeString(tostring(k)) .. '": ' .. encodedValue)
            end
        end

        if isArray then
            return "[\n" .. padInner .. table.concat(items, ",\n" .. padInner) .. "\n" .. pad .. "]"
        else
            return "{\n" .. padInner .. table.concat(items, ",\n" .. padInner) .. "\n" .. pad .. "}"
        end
    elseif type(value) == "string" then
        return '"' .. self:escapeString(value) .. '"'
    elseif type(value) == "number" or type(value) == "boolean" then
        return tostring(value)
    elseif value == nil then
        return "null"
    else
        self.logger:error("Unsupported type: " .. type(value), "Json")
    end
end


return Json