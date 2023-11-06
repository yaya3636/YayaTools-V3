Thread = {
    dependencies = {"packetManager", "mutex"},
    running = false,
    signatureFunc = nil,
    threadPacket = nil,
    threadName = nil
}

function Thread:init(threadPacket, threadName)
    self.threadPacket = threadPacket
    self.threadName = threadName
end

function Thread:cb(callback)
    if not self.running then
        self.running = true
        callback()
        self.logger:log(self.threadName .. " finished removing callback")
        self.running = false
        self.packetManager:removeCallback(self.threadPacket:getSubscribePacketName(), self.signatureFunc)
    end
end

function Thread:run(callback)
    self.logger:log("starting", self.threadName)
    if not self.running then
        local fn = function()
            self:cb(callback)
        end
        self.signatureFunc = tostring(fn)
        self.logger:log("subscribePacket")
        self.packetManager:subscribePacket(self.threadPacket:getSubscribePacketName(), fn)
        self.logger:log("sendPacket")
        self.packetManager:sendPacket(self.threadPacket:getSendPacketName())
    end
end

return Thread