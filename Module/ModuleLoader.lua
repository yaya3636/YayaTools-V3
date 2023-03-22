local moduleDirectory = global:getCurrentDirectory() .. [[\YayaToolsV3\Module\]]
local class = dofile(moduleDirectory .. "Class.lua")

local list = class("List", dofile(moduleDirectory .. "collections\\List.lua"))
list.newInstance = list
local dictionary = class("Dictionary", dofile(moduleDirectory .. "collections\\Dictionary.lua"))
dictionary.list = list
dictionary.newInstance = dictionary
local logger = class("Logger", dofile(moduleDirectory .. "utils\\Logger.lua"))
logger.dictionary = dictionary
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
    self.modulePaths = dictionary()
    self.modulePaths:add("List", moduleDirectory .. "collections\\List.lua")
    self.modulePaths:add("LinkedList", moduleDirectory .. "collections\\LinkedList.lua")
    self.modulePaths:add("Node", moduleDirectory .. "collections\\Node.lua")
    self.modulePaths:add("Dictionary", moduleDirectory .. "collections\\Dictionary.lua")
    self.modulePaths:add("Logger", moduleDirectory .. "utils\\Logger.lua")
    self.modulePaths:add("TypedObject", moduleDirectory .. "typeChecker\\TypedObject.lua")
    self.modulePaths:add("Person", moduleDirectory .. "typeChecker\\PersonTyped.lua")


    self.moduleLoaded = dictionary()
    self.moduleLoaded:add("class", class)

    self.logger = logger(loggerLevel)
    self.logger:filterHeader("dictionary", true)
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
    end
    if newClass == nil then
        self.logger:log("Le module [" .. moduleName .. "] n'éxiste pas vérifié l'hortographe !", "ModuleLoader", 3)
    end
    return newClass
end

function ModuleLoader:resolveDependencies(classDefinition)
    local dependencies = {}
    if classDefinition.dependencies then
        for _, dependencyPath in ipairs(classDefinition.dependencies) do
            local dependencyClass = self:load(dependencyPath)
            dependencies[string.lower(dependencyPath)] = dependencyClass
        end
    end
    return dependencies
end

function ModuleLoader:loadModuleFromFile(modulePath)
    local classDefinition = dofile(modulePath)

    local dependencies = self:resolveDependencies(classDefinition)
    local newClass

    newClass = class(modulePath:gsub("\\", "/"):match(".*/(.+)%.lua"), classDefinition)

    for depName, depClass in pairs(dependencies) do
        newClass[depName] = depClass
    end

    newClass.newInstance = function() return newClass() end
    newClass = addSecondaryInit(newClass, {logger = self.logger})

    return newClass
end

function ModuleLoader:listLoggerFilteredHeaders()
    return self.logger:listFilteredHeaders()
end

return ModuleLoader