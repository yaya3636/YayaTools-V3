Mutex = {
    dependencies = {"utils", "json"},
    url = "http://localhost:5054/Variables/",
    headers = {"Content-Type", "Accept", "Accept-Encoding", "Connection", "User-Agent", "Host"},
    headersContent = {"application/json", "*/*", "gzip, deflate, br", "keep-alive", "PostmanRuntime/7.32.3", "localhost:5054"}
}

function Mutex:init(ressource)
    self.uuid = self.utils:uuid()

end

function Mutex:storeValue(value, timeoutSeconds)
    local serializedData = self:getSerializedModelAPI(self.uuid, timeoutSeconds, value)
    local data = developer:postRequest(self.url .. "add", serializedData, self.headers, self.headersContent)
    --self.logger:log(self.json:decode(data))
end

function Mutex:getValue(timeoutSeconds)
    local serializedData = self:getSerializedModelAPI(self.uuid, timeoutSeconds)
    local data = self.json:decode(developer:postRequest(self.url .. "retrieve", serializedData, self.headers, self.headersContent))
    --self.logger:log(data)
    return data.value
end

function Mutex:modifyValue(value, timeoutSeconds)
    local serializedData = self:getSerializedModelAPI(self.uuid, timeoutSeconds, value)
    local data = developer:postRequest(self.url .. "modify", serializedData, self.headers, self.headersContent)
    --self.logger:log(self.json:decode(data))
end

function Mutex:getSerializedModelAPI(key, timeoutSeconds, value)
    if value then
        return self.json:encode({key = key, timeoutSeconds = timeoutSeconds, value = value})
    else
        return self.json:encode({key = key, timeoutSeconds = timeoutSeconds})
    end
end

-- function Mutex:init(ressource)
--     self.uuid = self.utils:uuid()
--     --global:addInMemory(self.uuid, ressource)
--     self.ressource = self.atomicVariable(ressource)
--     self.locked = self.atomicVariable(false)
--     --global:addInMemory(self.uuid .. "-locked", false)
-- end

-- function Mutex:lock()
--     global:printMessage("lock")
--     while self.locked:get() do
--         global:printMessage("attente du Déverrouillage")
--         --coroutine.yield()  -- Attendre de manière non bloquante
--     end
--     --global:editInMemory(self.uuid .. "-locked", true)  -- Verrouillage du mutex
--     self.locked:set(true)
--     return self.ressource:get()
-- end

-- function Mutex:unlock()
--     self.locked:set(false)
--     --global:editInMemory(self.uuid .. "-locked", false)  -- Déverrouillage du mutex
-- end

-- function Mutex:setRessource(ressource)
--     self.ressource:set(ressource)
-- end

return Mutex
