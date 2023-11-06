local movement = {
    dependencies = {"list", "dictionary", "areas", "subAreas"}
}


function movement:init()

end

function movement:roadZone(listMapId)
    if type(listMapId) ~= "table" then
        Logger:warning("Le paramètre listMapId doit être une liste ou une table. ![" .. type(listMapId) .. "]", "Movement;roadZone")
        return
    elseif not (listMapId.c ~= nil and listMapId.c.className == "List") then
        listMapId = self.list():fromTable(listMapId)
    end


end




-- Zone



return movement