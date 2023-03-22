local moduleLoader = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\ModuleLoader.lua]])(1)
local dictionary = moduleLoader:load("dictionary")
local list = moduleLoader:load("list")
local class = moduleLoader:load("class")
local list3 = moduleLoader:load("list")
local wrong = moduleLoader:load("listt")
local logger = moduleLoader:load("logger")(1)
local linkedList = moduleLoader:load("linkedList")


logger:log(class.isClass(list))
logger:log(tostring(dictionary))
logger:log(tostring(moduleLoader:listLoggerFilteredHeaders()))

moduleLoader.logger:setLevel(2)
moduleLoader.logger:setLevel(1)
moduleLoader.logger:setLevel(3)
moduleLoader.logger:setLevel(4)
moduleLoader.logger:setLevel(1)
moduleLoader.logger:setLevel(0)


local dic = dictionary()
local dic2 = dictionary()
local lst = list()
local lst2 = list()
local linked = linkedList()
local linked2 = linkedList()
logger:log(linked == linked2)
logger:log(lst == lst2)
logger:log(dic == dic2)


for i = 1, 10 do
    dic:add("Dic1-" .. i, i)
    dic2:add("Dic2-" .. i, i)
    lst:add("key" .. i)
    lst2:add("key" .. i)
    linked:insertAt(i, "key" .. i)
    linked2:insertAt(i, "key" .. i)
end

local dic3 = dic + dic2
local lst3 = lst + lst2
local linked3 = linked - linked2


logger:log(#dic)
logger:log(#lst)
logger:log(#linked)

logger:log(linked == linked2)
logger:log(lst == lst2)
logger:log(dic == dic2)

for k, v in pairs(linked3) do
    logger:log(k .. "|" .. v)
end

function move()
    local table = { "Test1", "Test2", "Test3", "Test4", "Test5" }
    local dic = dictionary()

    local lst = list()
    local lst2 = list:fromTable(table)

    local otherTest = logger:listFilteredHeaders()

    logger:log(tostring(otherTest))

    logger:log(tostring(moduleLoader.logger.filteredHeaders:getKeys()))

    logger:log(tostring(moduleLoader:listLoggerFilteredHeaders()))
    local test = moduleLoader:listLoggerFilteredHeaders()
    test:forEach(function(v)
        logger:log(tostring(v))
    end)

    lst:add("key")
    lst:add("key2")
    lst:add("key3")
    lst:add("key4")
    lst:add("key5")
    lst:add("key6")

    dic:add("key", 1)
    dic:add("key2", 2)
    dic:add("key3", 3)
    dic:add("key4", 4)
    dic:add("key5", 5)
    dic:add("key6", 6)

    local dicCopy = dic:copy()

    lst2 = dicCopy:getKeys()

    local merged = dictionary:mergeMultiple({ dic, dicCopy })


    dic:forEach(function(k, v)
        logger:log(k .. " | " .. v)
    end)

    dicCopy:forEach(function(k, v)
        logger:log(k .. " | " .. v)
    end)

    -- merged:forEach(function(k, v)
    --     logger:log(k .. " | " .. v, "dev")
    -- end)

    local keys = merged:getKeys()
    keys:forEach(function(v)
        logger:log(v, "dev")
    end)

    lst:forEach(function(v)
        logger:log(v)
    end)
    lst2:forEach(function(v)
        logger:log(v)
    end)
end

function bank()
    logger:log("Func bank")
end

function stopped()
    logger:log("Func stopped")
end
