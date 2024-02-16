local timer = {
    dependencies = {}
}

function timer:init(config)
    if config and type(config) == "table" then
        if config.startAtInit then
            self.startAt = os.time()
        else
            self.startAt = 0
        end

        if config.randomTimeToWait then
            self.timeToWait = global:random(config.min, config.max)
            self.logger:info("Temps avant fin du timer " .. self.timeToWait .. "s", "Timer")
        else
            self.timeToWait = config.timeToWait
        end
    else
        error("missing parameters timer:init()")
    end
end

function timer:start()
    self.startAt = os.time()
end

function timer:finish()
    if os.difftime(os.time(), self.startAt) >= self.timeToWait then
        return true
    end
    return false
end

return timer