local scheduler = {
    dependencies = {"shedulerTask", "list", "dictionary"}
}

function scheduler:init()
    self.tasks = self.dictionary()
    :add(os.date("%A", os.time({year=os.date("*t").year, month=1, day=2})), self.list())
    :add(os.date("%A", os.time({year=os.date("*t").year, month=1, day=3})), self.list())
    :add(os.date("%A", os.time({year=os.date("*t").year, month=1, day=4})), self.list())
    :add(os.date("%A", os.time({year=os.date("*t").year, month=1, day=5})), self.list())
    :add(os.date("%A", os.time({year=os.date("*t").year, month=1, day=6})), self.list())
    :add(os.date("%A", os.time({year=os.date("*t").year, month=1, day=7})), self.list())
    :add(os.date("%A", os.time({year=os.date("*t").year, month=1, day=1})), self.list())
end

local function timeToMinutes(timeStr)
    local hours, minutes = timeStr:match("(%d%d):(%d%d)")
    return tonumber(hours) * 60 + tonumber(minutes)
end

function scheduler:addTask(day, startTime, endTime, callback, autoDestroy)
    day = string.lower(day)
    local function isValidTimeFormat(timeStr)
        local pattern = "^%d%d:%d%d$"
        return timeStr:match(pattern) ~= nil
    end

    if not self.tasks:containsKey(day) then
        self.logger:warning("Le format du jour (" .. day .. ") n'est pas valide", "Sheduler")
        for key in pairs(self.tasks) do
            self.logger:warning("Format accepté : " .. key, "Sheduler")
        end
        return
    end

    if not isValidTimeFormat(startTime) then
        self.logger:warning("Format d'heure invalide (" .. startTime .. "), format valide (hh:mm)", "Sheduler")
        return false
    elseif not isValidTimeFormat(endTime) then
        self.logger:warning("Format d'heure invalide (" .. endTime .. "), format valide (hh:mm)", "Sheduler")
        return false
    end

    local startTimeMinutes = timeToMinutes(startTime)
    local endTimeMinutes = timeToMinutes(endTime)

    local newTask = self.shedulerTask(startTimeMinutes, endTimeMinutes, callback, autoDestroy)
    self.tasks:get(day):add(newTask)
end

function scheduler:runTasks()
    local day = os.date("%A")
    local currentTime = os.time()
    local currentTimeStr = os.date("%H:%M", currentTime)
    local currentTimeMinutes = timeToMinutes(currentTimeStr)

    local taskList = self.tasks:get(day)
    for i = 1, #taskList do
        local task = taskList:get(i)
        if currentTimeMinutes >= task.startTime and currentTimeMinutes <= task.endTime then
            task.callback()
            if task.autoDestroy then
                taskList:remove(i)
                i = i - 1
            end
        end
    end
end

return scheduler