DEVELOPER_MULTI_THREADING = true
local packetManager = {}
packetManager.dependencies = {"dictionary"}

function packetManager:init()
    self.subscribedPacket = self.dictionary()
    self.dump = string.dump
end

-- Enregistre un packet
function packetManager:registerPacket(kPacketName)
    if not self.subscribedPacket:containsKey(kPacketName) then
        self.logger:log(kPacketName, "Packet", 3)
        if developer:isMessageRegistred(kPacketName) then
            developer:unRegisterMessage(kPacketName)
        end
        self["suspendScriptUntil" .. kPacketName] = developer:suspendScriptUntil(kPacketName, 0, false, "", 1)
        self.subscribedPacket:add(kPacketName, self.dictionary())
    end
end

-- Ajoute un callback à un packet
function packetManager:addCallback(kPacketName, vCallBack)
    local signatureFunc = string.dump(vCallBack)
    if not self.subscribedPacket:get(kPacketName):some(function (k)
        if tostring(k) == tostring(signatureFunc) then
            return true
        end
    end) then
        self.logger:info("Ajout d'un callback au packet : " .. kPacketName, "Packet")
        self.subscribedPacket:get(kPacketName):add(tostring(signatureFunc), vCallBack)
        self["suspendScriptUntil" .. kPacketName] = developer:suspendScriptUntil(kPacketName, 0, false, "", 1)
    else
        self.logger:warning("La fonction de callback est déja définie au packet : " .. kPacketName, "Packet")
    end
end

-- Définit la fonction de callback pour un packet
function packetManager:setCallbackFunction(kPacketName)
    if not self[kPacketName] then
        self[kPacketName] = function(msg)
            local tblFunc = self.subscribedPacket:get(developer:typeOf(msg))
            for _, v in pairs(tblFunc) do
                v(msg)
            end
        end
    end
end

-- Souscrit à un packet
function packetManager:subscribePacket(kPacketName, vCallBack)
    local fn = function(msg) vCallBack(msg) end
    self:registerPacket(kPacketName)
    self:setCallbackFunction(kPacketName)
    self:addCallback(kPacketName, fn)
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

function packetManager:compareStrings(str1, str2)
    local len1 = #str1
    local len2 = #str2

    if len1 ~= len2 then
      return false
    end

    for i = 1, len1 do
        local s1 = string.sub(str1, i, i)
        local s2 = string.sub(str2, i, i)
      if s1 ~= s2 then
        self.logger:log("i = " .. i)
        self.logger:log(s1)
        self.logger:log(s2)
        return false
      end
    end

    return true
  end

return packetManager