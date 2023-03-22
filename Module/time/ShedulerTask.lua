local shedulerTask = {}

function shedulerTask:init(startTime, endTime, callback, autoDestroy)
    self.startTime = startTime
    self.endTime = endTime
    self.callback = callback
    self.autoDestroy = autoDestroy
end

return shedulerTask