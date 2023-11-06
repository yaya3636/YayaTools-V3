DEVELOPER_MULTI_THREADING = true
local packetManager = {
    singleton = true,
    dependencies = {"dictionary"}
}

function packetManager:init()
    self.subscribedPacket = self.dictionary()
end

-- Enregistre un packet
function packetManager:registerPacket(kPacketName)
    if not self.subscribedPacket:containsKey(kPacketName) then
        --self.logger:log(kPacketName, "Packet", 3)
        if developer:isMessageRegistred(kPacketName) then
            developer:unRegisterMessage(kPacketName)
        end
        self["suspendScriptUntil" .. kPacketName] = developer:suspendScriptUntil(kPacketName, 0, false, "", 1)
        self.subscribedPacket:add(kPacketName, self.dictionary())
    end
end

-- Ajoute un callback à un packet
function packetManager:addCallback(kPacketName, vCallBack)
    local signatureFunc = tostring(vCallBack)
    --self.logger:log(signatureFunc)
    if not self.subscribedPacket:get(kPacketName):some(function (k)
        if tostring(k) == tostring(signatureFunc) then
            return true
        end
    end) then
        self.logger:info("Ajout d'un callback au packet : " .. kPacketName, "Packet")
        self.subscribedPacket:get(kPacketName):add(tostring(signatureFunc), vCallBack)
        self["suspendScriptUntil" .. kPacketName] = developer:suspendScriptUntil(kPacketName, 0, false, "", 1)
    else
        self.logger:warning("La fonction de callback (" .. signatureFunc .. ") est déja définie au packet : " .. kPacketName, "Packet")
    end
end

-- Ajoute un callback à un packet
function packetManager:removeCallback(kPacketName, vCallBack)
    local signatureFunc
    if type(vCallBack) == "string" then
        if vCallBack:sub(1, 9) == "function:" then
            signatureFunc = vCallBack
        else
            self.logger:warning("La signature de callback (" .. tostring(vCallBack) .. ") n'est pas valide", "Packet")
            return
        end
    elseif type(vCallBack) == "function" then
        signatureFunc = tostring(vCallBack)
    else
        self.logger:warning("La fonction de callback (" .. tostring(vCallBack) .. ") n'est pas une fonction ou une signature de fonction", "Packet")
        return
    end

    self.logger:log(signatureFunc)
    if self.subscribedPacket:get(kPacketName):some(function (k)
        if tostring(k) == tostring(signatureFunc) then
            return true
        end
    end) then
        self.logger:info("Supression du callback au packet : " .. kPacketName, "Packet")
        self.subscribedPacket:get(kPacketName):remove(tostring(signatureFunc))
    else
        self.logger:warning("La fonction de callback (" .. signatureFunc .. ") n'éxiste pas au packet : " .. kPacketName, "Packet")
    end
end

-- Définit la fonction de callback pour un packet
function packetManager:setCallbackFunction(kPacketName)
    if not self[kPacketName] then
        self[kPacketName] = function(msg)
            local tblFunc = self.subscribedPacket:get(developer:typeOf(msg))
            for _, v in pairs(tblFunc) do
                v(msg, self.logger)
            end
        end
    end
end

-- Souscrit à un packet
function packetManager:subscribePacket(kPacketName, vCallBack)
    self:registerPacket(kPacketName)
    self:setCallbackFunction(kPacketName)
    self:addCallback(kPacketName, vCallBack)
    self:registerMessage(kPacketName)
end

-- Désinscrit un packet
function packetManager:unsubscribePacket(kPacketName)
    self:unregisterMessage(kPacketName)
    self.subscribedPacket:remove(kPacketName)
end

-- Enregistre un message
function packetManager:registerMessage(kPacketName)
    if not developer:isMessageRegistred(kPacketName) then
        developer:registerMessage(kPacketName, self[kPacketName])
    end
end

-- Désenregistre un message
function packetManager:unregisterMessage(kPacketName)
    if developer:isMessageRegistred(kPacketName) then
        self.logger:info("Désabonnement du packet : ".. kPacketName, "Packet")
        developer:unRegisterMessage(kPacketName)
    end
end

-- Gère les abonnements et désabonnements aux packets
function packetManager:subscribeMultipePackets(packetToSub)
    for kPacketName, vCallBack in pairs(packetToSub) do
        if type(vCallBack) == "function" then
            --self.logger:log(string.dump(vCallBack))
            self:subscribePacket(kPacketName, vCallBack)
        else
            self:unsubscribePacket(kPacketName)
        end
    end
end

function packetManager:sendPacket(packetName, fn)
    self.logger:info("Envoie du packet " .. packetName, "Packet")
    local msg = developer:createMessage(packetName)

    if fn ~= nil then
        msg = fn(msg)
    end

    developer:sendMessage(msg)
end

return packetManager