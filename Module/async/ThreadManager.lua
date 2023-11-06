ThreadManager = {
    dependencies = {"thread", "threadPacket", "list", "dictionary"},
    singleton = true
}

function ThreadManager:init()
    self.threads = self.dictionary()
    self.packets = self.list()
    self.packets
    :add(self.threadPacket("HaapiShopApiKeyMessage", "HaapiShopApiKeyRequestMessage"))
    :add(self.threadPacket("QuestListMessage", "QuestListRequestMessage"))

end

function ThreadManager:createThread(threadName)
    for k, v in pairs(self.threads) do
        if k == threadName then
            self.logger:log(threadName .. " already exists")
            return
        end
    end

    local threadPacket

    for k, v in pairs(self.packets) do
        if not v:isUsed() then
            threadPacket = v
            v:use()
            break
        end
    end

    if threadPacket == nil then
        self.logger:log("No packet available")
        return
    end

    self.threads:add(threadName, self.thread(threadPacket, threadName))
    return self.threads:get(threadName)
end


return ThreadManager