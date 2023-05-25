local moduleLoader = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\ModuleLoader.lua]])(1)
local dictionary = moduleLoader:load("dictionary")
local list = moduleLoader:load("list")
local class = moduleLoader:load("class")
local list3 = moduleLoader:load("list")
local wrong = moduleLoader:load("listt")
local logger = moduleLoader:load("logger")(1)
local linkedList = moduleLoader:load("linkedList")
local json = moduleLoader:load("Json")()
Packet = moduleLoader:load("PacketManager")
Monsters = moduleLoader:load("Monsters")()
Recipes = moduleLoader:load("Recipes")()

local init = false

function move()
    local model = {}
    model.memberName = "Leader Test"
    model.bankItems = {}
    for _, v in pairs(exchange:storageItems()) do
        table.insert(model.bankItems, {id = v, count = exchange:storageItemQuantity(v)})
    end
    logger:log(json:encode(model))
end

function bank()
    logger:log("Func bank")
end

function stopped()
    logger:log("Func stopped")
end

function MeasureExecutionTime(functionToExecute, ...)
    local startTime = os.clock()
    local results = { functionToExecute(...) }
    local endTime = os.clock()
    local executionTime = endTime - startTime

    return executionTime, unpack(results)
end
