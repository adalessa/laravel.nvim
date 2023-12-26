local recipes = {
  ["ide-helper"] = require "laravel.recipes.ide-helper",
}

local M = {}

function M.run()
  vim.ui.select(vim.tbl_keys(recipes), { prompt = "Recipe to run:" }, function(recipeName)
    local recipe = recipes[recipeName]
    if recipe == nil then
      error(string.format("Recipe %s not found", recipeName), vim.log.levels.ERROR)
    end

    recipe.run()
  end)
end

return M
