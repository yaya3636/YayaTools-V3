local pushbullet = {
    dependencies = { "list", "myjson" },
    tokenApi = nil,
    pushbulletUrl = "https://api.pushbullet.com/v2/",
}

function pushbullet:init(tokenApi)
    self.tokenApi = tokenApi
    self.devices = self.list()
end

function pushbullet:getAllDevices()
    local headersName = { "Access-Token" }
    local headersContent = { self.tokenApi }
    local data =  developer:getRequest(self.pushbulletUrl .. "devices", headersName, headersContent)

    if data then
        return self.myjson:decode(data)
    end

    return nil
end

function pushbullet:send(title, body)
    local encoded = MyJson:encode({
        type = "note",
        title = title,
        body = body
    })


    local headersName = { "Access-Token", "Content-Type" }
    local headersContent = { self.tokenApi, "application/json" }
    local data = developer:postRequest(self.pushbulletUrl .. "pushes", encoded, headersName, headersContent)

    if data then
        return self.myjson:decode(data)
    end
    return nil
end

return pushbullet