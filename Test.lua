local moduleLoader = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\ModuleLoader.lua]])(1)
local dictionary = moduleLoader:load("dictionary")
local list = moduleLoader:load("list")
local class = moduleLoader:load("class")
local list3 = moduleLoader:load("list")
local wrong = moduleLoader:load("listt")
local logger = moduleLoader:load("logger")(1)
local linkedList = moduleLoader:load("linkedList")

local sheduler = moduleLoader:load("sheduler")

sheduler = sheduler()

sheduler:addTask("mercred", "21:30", "2:58", function() logger:log("Hello from task") end)
sheduler:addTask("mercredi", "21:30", "2:58", function() logger:log("Hello from task") end)
sheduler:addTask("mercredi", "21:30", "22:58", function() logger:log("Hello from task") end)
sheduler:addTask("mercredi", "21:30", "22:58", function() logger:log("Hello from task, autodestruct") end, true)

function move()
    while true do
        sheduler:runTasks()
        global:delay(500)
    end
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
