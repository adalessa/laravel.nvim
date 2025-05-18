local Class = require("laravel.class")

local gf = Class()

function gf:cursorOnResource()
    local node = vim.treesitter.get_node()
    if not node then
        return false
    end

    if node:type() ~= "string_content" then
        return false
    end

    local parent = node:parent()
    while parent ~= nil and parent:type() ~= "function_call_expression" do
        parent = parent:parent()
    end

    if not parent then
        return false
    end

    local func_node = parent:child(0)
    if not func_node then
        return false
    end

    local func_name = vim.treesitter.get_node_text(func_node, 0, {})

    if vim.tbl_contains({'route', 'view', 'config', 'env'}, func_name) then
        return node, func_name
    end

    return false
end

return gf
