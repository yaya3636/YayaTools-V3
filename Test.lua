ModuleLoader = dofile(global:getCurrentDirectory() .. [[Sandbox\YayaToolsV3\Module\ModuleLoader.lua]])(1)
PacketManager = ModuleLoader:load("PacketManager")
Loggerr = ModuleLoader:load("logger")(1)
Utils = ModuleLoader:load("Utils")()
Json = ModuleLoader:load("Json")()

Dictionary = ModuleLoader:load("dictionary")
List = ModuleLoader:load("list")
Player = ModuleLoader:load("Player")

function move()
end

function messagesRegistering()
    ModuleLoader:initCallback()
end

function bank()
    global:printMessage("Func bank")
end

function stopped()
    Stop = true
    global:printMessage("Func stopped")
    global:deleteAllMemory()
end
