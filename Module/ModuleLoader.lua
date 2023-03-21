local moduleDirectory = global:getCurrentDirectory() .. [[\YayaToolsV3\Module\]]
local class = dofile(moduleDirectory .. "Class.lua")

local list = class("List", dofile(moduleDirectory .. "list\\List.lua"))
local dictionary = class("Dictionary", dofile(moduleDirectory .. "dictionary\\Dictionary.lua"))
dictionary.list = list

local typedObject = class("TypedObject", dofile(moduleDirectory .. "typeChecker\\TypedObject.lua"))

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
    self.modulePaths:add("List", moduleDirectory .. "list\\List.lua")
    self.modulePaths:add("Dictionary", moduleDirectory .. "dictionary\\Dictionary.lua")
    self.modulePaths:add("Logger", moduleDirectory .. "utils\\Logger.lua")
    self.modulePaths:add("TypedObject", moduleDirectory .. "typeChecker\\TypedObject.lua")
    self.modulePaths:add("Person", moduleDirectory .. "typeChecker\\PersonTyped.lua")


    self.moduleLoaded = dictionary()
    self.moduleLoaded:add("class", class)

    self.logger = class("Logger", dofile(moduleDirectory .. "utils\\Logger.lua"))
    self.logger.dictionary = dictionary
    self.logger = self.logger(loggerLevel)

end

function ModuleLoader:load(moduleName)
    local newClass

    if self.moduleLoaded:contains(moduleName) then
        newClass = self.moduleLoaded:get(moduleName)
    else
        self.modulePaths:forEach(function(knownModuleName, modulePath)
            if string.lower(knownModuleName) == string.lower(moduleName) then
                local classDefinition = dofile(modulePath)

                local dependencies = {}
                if classDefinition.dependencies then
                    for _, dependencyPath in ipairs(classDefinition.dependencies) do
                        local dependencyClass = self:load(dependencyPath)
                        dependencies[string.lower(dependencyPath)] = dependencyClass
                    end
                end

                if classDefinition.isTypedObject then
                    newClass = typedObject:extend(moduleName)
                else
                    newClass = class(moduleName, classDefinition) 
                end

                for depName, depClass in pairs(dependencies) do
                    newClass[depName] = depClass
                end


                newClass.newInstance = function() return newClass() end
                newClass = addSecondaryInit(newClass, {logger = self.logger})

                self.moduleLoaded:add(string.lower(moduleName), newClass)
            end
        end)
    end

    if newClass == nil then
        self.logger:log("Le module [" .. moduleName .. "] n'éxiste pas vérifié l'hortographe !", "ModuleLoader", 3)
    end
    return newClass
end

return ModuleLoader