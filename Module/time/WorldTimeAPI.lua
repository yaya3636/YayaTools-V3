local worldTimeAPI = {
    dependencies = {"list", "dictionary", "json"}
}


worldTimeAPI.days = {
    [1] = "Lundi",
    [2] = "Mardi",
    [3] = "Mercredi",
    [4] = "Jeudi",
    [5] = "Vendredi",
    [6] = "Samedi",
    [7] = "Dimanche"
}

function worldTimeAPI:init()
end

function worldTimeAPI:requestAPI()
    return self.json:decode(developer:getRequest("https://worldtimeapi.org/api/ip/"))
end

function worldTimeAPI:getTime(format)
    local req = self:requestAPI()
    local actualTime = self:convertUnix(req.unixtime, req.utc_offset)
    if format then
        local hours, minutes, seconds = string.match(actualTime, "(%d+):(%d+):(%d+)")
        local result = {}
        for component in format:gmatch("%a") do
            if component == "h" then
                result.hour = tonumber(hours)
            elseif component == "m" then
                result.minute = tonumber(minutes)
            elseif component == "s" then
                result.second = tonumber(seconds)
            end
        end
        return result
    end
    return actualTime
end


function worldTimeAPI:convertUnix(unixTime, utcOffset)
    local secondesJour = 24 * 60 * 60 -- Nombre de secondes dans une journée

    local secondesDepuisMinuit = unixTime % secondesJour -- Calculer le nombre de secondes écoulées depuis minuit
    local secondesDepuisDecalage = secondesDepuisMinuit + (self:convertOffsetUTC(utcOffset) * 60 * 60) -- Ajouter le décalage horaire

    local heure = math.floor(secondesDepuisDecalage / 3600) -- Calculer les heures
    local minute = math.floor((secondesDepuisDecalage % 3600) / 60) -- Calculer les minutes
    local seconde = secondesDepuisDecalage % 60 -- Calculer les secondes

    local heureLocale = string.format("%02d:%02d:%02d", heure, minute, seconde) -- Construire l'heure au format HH:MM:SS

    return heureLocale
end

function worldTimeAPI:convertOffsetUTC(offset)
    local signe = string.sub(offset, 1, 1) -- Extraire le premier caractère (+ ou -)
    local heures = tonumber(string.sub(offset, 2, 3)) -- Extraire les deux chiffres pour les heures
    local minutes = tonumber(string.sub(offset, 5, 6)) -- Extraire les deux chiffres pour les minutes

    local decalageHoraire = heures + (minutes / 60) -- Calculer le décalage horaire en heures décimales

    if signe == "-" then
        decalageHoraire = -decalageHoraire -- Inverser le décalage horaire si le signe est négatif
    end

    return decalageHoraire
end

function worldTimeAPI:getDay()
    local req = self:requestAPI()
    return self.days[req.day_of_week]
end

return worldTimeAPI