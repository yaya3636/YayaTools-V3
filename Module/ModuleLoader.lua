local moduleDirectory = global:getCurrentDirectory() .. [[\YayaToolsV3\Module\]]
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

local function addSecondaryInit(c, attributes)
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

function ModuleLoader:init(loggerLevel)
    self.singletonInstances = dictionary()
    self.modulePaths = dictionary()
    self.modulePaths:add("List", moduleDirectory .. "collections\\List.lua")
    :add("LinkedList", moduleDirectory .. "collections\\LinkedList.lua")
    :add("Node", moduleDirectory .. "collections\\Node.lua")
    :add("Dictionary", moduleDirectory .. "collections\\Dictionary.lua")
    :add("Logger", moduleDirectory .. "utils\\Logger.lua")
    :add("TypedObject", moduleDirectory .. "typeChecker\\TypedObject.lua")
    :add("Person", moduleDirectory .. "typeChecker\\PersonTyped.lua")
    :add("Sheduler", moduleDirectory .. "time\\Sheduler.lua")
    :add("ShedulerTask", moduleDirectory .. "time\\ShedulerTask.lua")
    :add("PacketManager", moduleDirectory .. "packet\\PacketManager.lua")
    :add("AStar", moduleDirectory .. "map\\AStar.lua")
    :add("AStarNode", moduleDirectory .. "map\\AStarNode.lua")
    :add("Json", moduleDirectory .. "utils\\Json.lua")
    :add("Areas", moduleDirectory .. "map\\Areas.lua")
    :add("SubAreas", moduleDirectory .. "map\\SubAreas.lua")
    :add("Monsters", moduleDirectory .. "monsters\\Monsters.lua")
    :add("Recipes", moduleDirectory .. "recipes\\Recipes.lua")


    self.moduleLoaded = dictionary()
    self.moduleLoaded:add("class", class)

    self.logger = logger(loggerLevel)
    self.logger:filterHeader("Dictionary", true)
end

function ModuleLoader:load(moduleName)
    local newClass

    if self.moduleLoaded:containsKey(moduleName) then
        newClass = self.moduleLoaded:get(moduleName)
    else
        self.modulePaths:forEach(function(knownModuleName, modulePath)
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

function ModuleLoader:updateClassDependency()
    for moduleName, module in pairs(self.moduleLoaded) do
        if module.class then
            module.class = class
        end
    end
end

function ModuleLoader:resolveDependencies(classDefinition)
    local dependencies = {}
    if classDefinition.dependencies then
        for _, dependencyPath in ipairs(classDefinition.dependencies) do
            local dependencyClass = self:load(dependencyPath)
            dependencies[dependencyPath] = dependencyClass
        end
    end
    return dependencies
end

function ModuleLoader:getSingletonInstance(moduleName, classDefinition)
    if not self.singletonInstances:containsKey(moduleName) then
        local instance = classDefinition()
        self.singletonInstances:add(moduleName, instance)
    end
    return self.singletonInstances:get(moduleName)
end

function ModuleLoader:loadModuleFromFile(modulePath)
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

function ModuleLoader:listLoggerFilteredHeaders()
    return self.logger:listFilteredHeaders()
end

return ModuleLoader