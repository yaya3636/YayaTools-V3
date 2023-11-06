ThreadPacket = {
    used = false
}

function ThreadPacket:init(subscribePacketName, sendPacketName)
    self.subscribePacketName = subscribePacketName
    self.sendPacketName = sendPacketName
end

function ThreadPacket:getSubscribePacketName()
    return self.subscribePacketName
end

function ThreadPacket:getSendPacketName()
    return self.sendPacketName
end

function ThreadPacket:use()
    self.used = true
    return self:getSubscribePacketName(), self:getSendPacketName()
end

function ThreadPacket:isUsed()
    return self.used
end

return ThreadPacket