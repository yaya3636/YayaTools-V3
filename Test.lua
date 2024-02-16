ModuleLoader = dofile(global:getCurrentDirectory() .. [[Sandbox\YayaToolsV3\Module\ModuleLoader.lua]])(1)
Loggerr = ModuleLoader:load("logger")(1)
Utils = ModuleLoader:load("Utils")()
Pushbullet = ModuleLoader:load("Pushbullet")("TokenAPIIci")
MyJson = ModuleLoader:load("MyJson")()

function move()
    Loggerr:log(Pushbullet:send("test", "Message de test"))
end

function bank()
    global:printMessage("Func bank")
end

function stopped()
    Stop = true
    global:printMessage("Func stopped")
    global:deleteAllMemory()
end
