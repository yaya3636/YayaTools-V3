local scheduler = {
    dependencies = {"shedulerTask", "worldTimeAPI", "list", "dictionary"}
}

function scheduler:init()
    self.tasks = self.dictionary()
    :add("lundi", self.list())
    :add("mardi", self.list())
    :add("mercredi", self.list())
    :add("jeudi", self.list())
    :add("vendredi", self.list())
    :add("samedi", self.list())
    :add("dimanche", self.list())
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
    self.logger:info("La tâche a bien été ajouté !", "Sheduler")
end

function scheduler:runTasks()
    local day = string.lower(self.worldTimeAPI:getDay())
    --self.logger:log(day)
    local currentTime = self.worldTimeAPI:getTime("h,m")
    --self.logger:log(currentTime)
    local currentTimeMinutes = timeToMinutes(currentTime.hour .. ":" .. currentTime.minute)

    local taskList = self.tasks:get(day)
    for i = 1, #taskList do
        local task = taskList:get(i)
        --self.logger:log(task)
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