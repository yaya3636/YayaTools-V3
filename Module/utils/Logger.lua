local moduleDirectory = global:getCurrentDirectory() .. [[\YayaToolsV3\Module\]]
local class = dofile(moduleDirectory .. "Class.lua")
local dictionary = dofile(moduleDirectory .. "dictionary\\Dictionary.lua")

local Logger = class('Logger')

function Logger:init(level, showTimestamp)
    self.levels = dictionary()
    self.levels:add("DEBUG", 1)
    self.levels:add("INFO", 2)
    self.levels:add("WARNING", 3)
    self.levels:add("ERROR", 4)

    self.colors = dictionary()
    self.colors:add("DEBUG", "0x00FF00")
    self.colors:add("INFO", "0x00FFFF")
    self.colors:add("WARNING", "0xFFFF00")
    self.colors:add("ERROR", "0xFF0000")

    global:printMessage(tostring(self.levels))

    self.level = level or self.levels:get("DEBUG")
    self.showTimestamp = showTimestamp or false
    global:printMessage(tostring(self.levels))
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
        if header then
            color = self.colors:get(header:upper()) or self.colors:get(levelName)
            message = "[" .. header .. "] " .. message
        end
        local timestamp = self.showTimestamp and self:getTimestamp() or ""
        global:printColor(color, timestamp .. "[" .. levelName .. "] " .. message)
    end
end

function Logger:addHeaderColor(header, color)
    self.colors:add(header:upper(), color)
    self:log("Couleur ajoutée pour l'en-tête " .. header, "Logger", 2)
end

return Logger
