local moduleDirectory = global:getCurrentDirectory() .. [[\YayaToolsV3\Module\]]

local class = dofile(moduleDirectory .. "Class.lua")
local dictionary = dofile(moduleDirectory .. "dictionary\\Dictionary.lua")
local logger = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\utils\Logger.lua]])

ModuleLoader = class('ModuleLoader')

function ModuleLoader:init(loggerLevel)
    self.loggerLevel = loggerLevel or 2
    self.paths = dictionary()
    self.classLoaded = dictionary()
    self.paths:add("Dictionary", moduleDirectory .. "dictionary\\Dictionary.lua")
    self.paths:add("List", moduleDirectory .. "list\\List.lua")
    self.paths:add("Logger", moduleDirectory .. "utils\\Logger.lua")
    self.logger = logger(self.loggerLevel)
end

-- Fonction pour ajouter un chemin de module
function ModuleLoader:addPath(path)
end

-- Fonction pour charger un module par son nom
function ModuleLoader:load(moduleName)
    local ret
    if not self.classLoaded:contains(string.lower(moduleName)) then
        self.paths:forEach(function(k, modulePath)
            if string.lower(k) == string.lower(moduleName) then
                ret = dofile(modulePath)
                self.classLoaded:add(string.lower(moduleName), ret)
                return
            end
        end)
    else
        ret = self.classLoaded:get(string.lower(moduleName))
    end

    if not ret then
        self.logger:log("Le module [" .. moduleName .. "] n'éxiste pas vérifié l'hortographe !", "ModuleLoader", 4)
        return nil
    end

    ret.loggerLevel = self.loggerLevel
    ret.logger = self.logger
    return ret
end

return ModuleLoader
