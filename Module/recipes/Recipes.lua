local recipes = {
    dependencies = { "list", "dictionary" }
}

function recipes:init()
    
end

function recipes:getRecipesObject(recipeId)
    local recipe = d2data:objectFromD2O("Recipes", recipeId)
    if recipe then
        recipe = recipe.Fields
        local parseIngredients = function(ingredients, quantities)
            local ret = self.list()
            for i = 1, #ingredients do
                ret:add({
                    ingredientId = ingredients[i],
                    quantities = quantities[i]
                })
            end
            return ret
        end
        local obj = recipe
        obj.ingredientIds = parseIngredients(recipe.ingredientIds, recipe.quantities)
        obj.quantities = self.list:fromTable(recipe.quantities)
        return obj
    else
        self.logger:warning("Recipe not found: " .. recipeId, "Recipes")
    end
end

function recipes:getJobId(craftId)
    local recipe = self:getRecipesObject(craftId)
    if recipe then return recipe.jobId end
    return nil
end

function recipes:getSkillId(craftId)
    local recipe = self:getRecipesObject(craftId)
    if recipe then return recipe.skillId end
    return nil
end

function recipes:getLevel(craftId)
    local recipe = self:getRecipesObject(craftId)
    if recipe then return recipe.resultLevel end
    return nil
end

function recipes:getTypeId(craftId)
    local recipe = self:getRecipesObject(craftId)
    if recipe then return recipe.resultTypeId end
    return nil
end

function recipes:getIngredients(craftId)
    local recipe = self:getRecipesObject(craftId)
    if recipe then return recipe.ingredientIds end
    return nil
end

return recipes