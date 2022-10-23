local M = {
    actions = {}
}

M.actions["HasOne"] = require("laravel.code-actions.relationships.has_one")
M.actions["BelongsTo"] = require("laravel.code-actions.relationships.belongs_to")
M.actions["HasMany"] = require("laravel.code-actions.relationships.has_many")

---Action for new relationship
---@param class laravel.class
---@return function
function M.action (class)
    return function()
        vim.ui.select(vim.tbl_keys(M.actions), {}, function(relationType)
            if relationType == nil then
                return
            end
            vim.ui.input({ prompt = "Model: " }, function(model)
                if model == nil then
                    return
                end
                vim.ui.input(
                    { prompt = "Name: ", default = model:gsub("^%L", string.lower) },
                    function(name)
                        if name == nil then
                            return
                        end
                        -- call the actual method
                        M.actions[relationType](class, model, name)
                    end)
            end)
        end)
    end
end

return M
