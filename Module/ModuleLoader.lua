local moduleDirectory = global:getCurrentDirectory() .. [[Sandbox\YayaToolsV3\Module\]]
local class = dofile(moduleDirectory .. "Class.lua")

local list = class("List", dofile(moduleDirectory .. "collections\\List.lua"))
list.newInstance = list

local dictionary = class("Dictionary", dofile(moduleDirectory .. "collections\\Dictionary.lua"))
dictionary.list = list
dictionary.newInstance = dictionary

local logger = class("Logger", dofile(moduleDirectory .. "utils\\Logger.lua"))
logger.dictionary = dictionary
logger.list = list
logger.class = class
logger.newInstance = logger

local ModuleLoader = class('ModuleLoader')

local function addSecondaryInit(c, attributes) -- Fonction de surcharge de l'init
    local originalInit = c.init

    c.init = function(self, ...)
        if originalInit then
            originalInit(self, ...)
        end

        for k, v in pairs(attributes) do
            self[k] = v
        end
    end

    return c
end

function ModuleLoader:init(loggerLevel) -- Initialise le ModuleLoader
    self.logger = logger(loggerLevel)
    self.logger:filterHeader("Dictionary", true)


    self.moduleLoaded = dictionary()
    self.moduleLoaded:add("class", class)

    self.singletonInstances = dictionary()
    self.modulesPaths = dictionary()
    self.modulesDirectory = list()
    self.modulesDirectory
    :add("async")
    :add("collections")
    :add("fight")
    :add("map")
    :add("monsters")
    :add("packet")
    :add("player")
    :add("recipes")
    :add("time")
    :add("utils")

    for _, v in pairs(self.modulesDirectory) do
        local allFilesName = global:getAllFilesNameInDirectory(moduleDirectory .. v, ".lua")
        for _, v2 in pairs(allFilesName) do
            --self.logger:log("Module " .. v2:gsub("%.lua$", "") .. " loaded")
            self.modulesPaths:add(v2:gsub("%.lua$", ""), moduleDirectory .. v .. "\\" .. v2)
        end
    end

    self.moduleLoaded = dictionary()
    self.moduleLoaded:add("class", class)
    --self.modulesPaths:getKeys():forEach(function(mod) self:load(mod) end)
end

function ModuleLoader:initCallback() -- Initialise les callbacks de tout les modules chargé
    PacketManager = self:load("PacketManager")
    for modName, mod in pairs(self.moduleLoaded) do
        if mod.initCallback then
            for k, v in pairs(mod) do
                if string.sub(k, 1, 3) == "cb_" then
                    PacketManager:subscribePacket(string.sub(k, 4, #k), v)
                end
            end
        end
    end
end

function ModuleLoader:load(moduleName) -- Fonction pour charger un module
    local newClass

    if self.moduleLoaded:containsKey(moduleName) then
        newClass = self.moduleLoaded:get(moduleName)
    else
        self.modulesPaths:forEach(function(knownModuleName, modulePath)
            if string.lower(knownModuleName) == string.lower(moduleName) then
                newClass = self:loadModuleFromFile(modulePath)
                self.moduleLoaded:add(string.lower(moduleName), newClass)
                return
            end
        end)
        if newClass == nil then
            self.logger:log("Le module [" .. moduleName .. "] n'éxiste pas vérifié l'hortographe !", "ModuleLoader;Fonction (load)", 3)
        else
            self.moduleLoaded:set("class", class)
            self:updateClassDependency()
        end
    end
    if newClass and newClass.singleton then
        return self:getSingletonInstance(moduleName, newClass)
    end
    return newClass
end

function ModuleLoader:updateClassDependency() -- Met a jour les class chargé par ( class ) dans tous les modules
    for moduleName, module in pairs(self.moduleLoaded) do
        if module.class then
            module.class = class
        end
    end
end

function ModuleLoader:resolveDependencies(classDefinition) -- Fournit les dépendances requise pour les modules chargé
    local dependencies = {}
    if classDefinition.dependencies then
        for _, dependencyPath in ipairs(classDefinition.dependencies) do
            local dependencyClass = self:load(dependencyPath)
            dependencies[dependencyPath] = dependencyClass
        end
    end
    return dependencies
end

function ModuleLoader:getSingletonInstance(moduleName, classDefinition) -- Renvoie une instance unique d'un module
    if not self.singletonInstances:containsKey(moduleName) then
        local instance = classDefinition()
        self.singletonInstances:add(moduleName, instance)
    end
    return self.singletonInstances:get(moduleName)
end

function ModuleLoader:loadModuleFromFile(modulePath) -- Charge et prépare un module
    local classDefinition = dofile(modulePath)

    local dependencies = self:resolveDependencies(classDefinition)
    local newClass

    newClass = class(modulePath:gsub("\\", "/"):match(".*/(.+)%.lua"), classDefinition)

    for depName, depClass in pairs(dependencies) do
        newClass[depName] = depClass
    end

    if not classDefinition.noNewInstance then
        newClass.newInstance = function() return newClass() end
    end

    if not classDefinition.noLogger then
        newClass = addSecondaryInit(newClass, {logger = self.logger})
    end
    
    return newClass
end

function ModuleLoader:listLoggerFilteredHeaders() -- Renvoie la liste des headers filtre
    return self.logger:listFilteredHeaders()
end

return ModuleLoader