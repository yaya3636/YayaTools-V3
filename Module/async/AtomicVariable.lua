local AtomicVariable = {}

function AtomicVariable:init(value)
    self.value = value
    self.co = coroutine.create(function()
        while true do
            -- Attendre une action
            local action, newValue = coroutine.yield(self.value)
            if action == "set" then
                -- Mettre à jour la valeur
                self.value = newValue
            elseif action == "get" then
                -- La valeur est déjà retournée par yield
            end
        end
    end)
    -- Commencer la coroutine
    coroutine.resume(self.co)
end

function AtomicVariable:set(newValue)
    -- Réveiller la coroutine pour définir la nouvelle valeur
    coroutine.resume(self.co, "set", newValue)
end

function AtomicVariable:get()
    -- Réveiller la coroutine et obtenir la valeur actuelle
    return select(2, coroutine.resume(self.co, "get"))
end

return AtomicVariable