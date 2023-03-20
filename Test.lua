local moduleLoader = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\ModuleLoader.lua]])(1)
local dictionary = moduleLoader:load("dictionary")
local list = moduleLoader:load("list")
local wrong = moduleLoader:load("listt")
local logger = moduleLoader:load("logger")(1)

logger:log(list.logger)

function move()
    local dic = dictionary()

    local lst = list()

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

    local merged = dictionary.mergeMultiple({dic, dicCopy})

    -- dic:foreach(function(k, v)
    --     global:printMessage(k .. " | " .. v)
    -- end)

    -- dicCopy:foreach(function(k, v)
    --     global:printMessage(k .. " | " .. v)
    -- end)

    merged:forEach(function(k, v)
        logger:log(k .. " | " .. v, "dev")
    end)

    local keys = merged:getKeys()
    keys:forEach(function(v)
        logger:log(v, "dev")
    end)

    -- lst:forEach(function(v)
    --     global:printMessage(v)
    -- end)

end

function bank()
    global:printMessage("Func bank")
end

function stopped()
    global:printMessage("Func stopped")
end