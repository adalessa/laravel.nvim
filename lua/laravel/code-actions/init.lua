local null_ls = require("null-ls")
local Class = require("laravel.class")
local relationships = require("laravel.code-actions.relationships")

local M = {}

M.relationships = {
    method = null_ls.methods.CODE_ACTION,
    filetypes = { "php" },
    generator = {
        fn = function(context)
            local class = Class:new(context.bufnr)
            -- Todo allow to customize this maybe an option
            if not class.namespace == "App\\Models" then
                return
            end

            return {
                {
                    title = "Create Relationship",
                    action = relationships.action(class),
                }
            }
        end,
    },
}

return M
