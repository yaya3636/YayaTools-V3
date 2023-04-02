RECONNECT_ON_TIMEOUT = false
local moduleLoader = dofile(global:getCurrentDirectory() .. [[\YayaToolsV3\Module\ModuleLoader.lua]])(1)
local logger = moduleLoader:load("logger")(1)
local packet = moduleLoader:load("PacketManager")()


function move()
    main()
end

function main()
    if quest:questActive(489) then
        if map:currentMapId() == 153092354 then -- MapId Spawn
            packet:sendPacket("GuidedModeReturnRequestMessage")
            global:delay(2500)
        end
        while true do
            local currentStep = quest:questCurrentStep(489)
            logger:log(currentStep)


            if currentStep == 1042 then -- Ce déplacer

                global:delay(1500)
                map:moveToCell(443)
                --global:thisAccountController():stopScript()

            elseif currentStep == 1043 then -- Parler a ganymede
                packet:sendPacket("NpcGenericActionRequestMessage", function(msg)
                    msg.npcId = -20000
                    msg.npcActionId = 3
                    msg.npcMapId = map:currentMapId()
                    return msg
                end)
                global:delay(1000)
                npc:reply(-1)
            elseif currentStep == 1044 then -- Equiper l'anneau
                local uid = inventory:getUID(10785)
                packet:sendPacket("ObjectSetPositionMessage", function(msg)
                    msg.objecttUID = uid
                    msg.position = 2
                    msg.quantity = 1
                    return msg
                end)

                quest:validateObjective(489, 3502)

            elseif currentStep == 1045 then -- Changer de map
                map:changeMap("right")
            elseif currentStep == 1046 then -- Fight
                quest:validateObjective(489, 3504)
            elseif currentStep == 1052 then -- Parler a ganymede
                packet:sendPacket("NpcGenericActionRequestMessage", function(msg)
                    msg.npcId = -20000
                    msg.npcActionId = 3
                    msg.npcMapId = map:currentMapId()
                    return msg
                end)
                global:delay(2000)
                npc:reply(-1)
            elseif currentStep == 1060 then -- Equiper les objet

                local uid = inventory:getUID(10784) -- Amulette
                packet:sendPacket("ObjectSetPositionMessage", function(msg)
                    msg.objecttUID = uid
                    msg.position = 0
                    msg.quantity = 1
                    return msg
                end)

                uid = inventory:getUID(10794) -- Bottes
                packet:sendPacket("ObjectSetPositionMessage", function(msg)
                    msg.objecttUID = uid
                    msg.position = 5
                    msg.quantity = 1
                    return msg
                end)

                uid = inventory:getUID(10797) -- Epée
                packet:sendPacket("ObjectSetPositionMessage", function(msg)
                    msg.objecttUID = uid
                    msg.position = 1
                    msg.quantity = 1
                    return msg
                end)

                uid = inventory:getUID(10798) -- Bouclier
                packet:sendPacket("ObjectSetPositionMessage", function(msg)
                    msg.objecttUID = uid
                    msg.position = 15
                    msg.quantity = 1
                    return msg
                end)

                uid = inventory:getUID(10799) -- Ceinture
                packet:sendPacket("ObjectSetPositionMessage", function(msg)
                    msg.objecttUID = uid
                    msg.position = 3
                    msg.quantity = 1
                    return msg
                end)

                uid = inventory:getUID(10800) -- Cape
                packet:sendPacket("ObjectSetPositionMessage", function(msg)
                    msg.objecttUID = uid
                    msg.position = 7
                    msg.quantity = 1
                    return msg
                end)

                quest:validateObjective(489, 3530)
                global:delay(1000)
                map:changeMap("right")
            elseif currentStep == 1053 then -- Affronter le monstre
                quest:validateObjective(489, 3513)
                --logger:printTable(quest:questRemainingObjectives(489))
            elseif currentStep == 1061 then -- Affronter le monstre
                quest:validateObjective(489, 3531)
            elseif currentStep == 1059 then -- Parler a ganymède
                packet:sendPacket("NpcGenericActionRequestMessage", function(msg)
                    msg.npcId = -20000
                    msg.npcActionId = 3
                    msg.npcMapId = map:currentMapId()
                    return msg
                end)
                global:delay(1000)
                npc:reply(-1)
            end
    

    
            global:delay(2500)
        end
    else
        logger:log("La quête du tutoriel n'est pas disponible", "Quest", 2)
    end    
end

global:thisAccountController():startScript()
