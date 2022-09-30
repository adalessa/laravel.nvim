local artisan = require("laravel.artisan")
local utils = require("laravel.utils")

local route_info = {}

local get_node_text = vim.treesitter.get_node_text

vim.treesitter.set_query(
    "php",
    "laravel_route_info",
    [[
        (namespace_definition (namespace_name) @namespace)
        (class_declaration (name) @class)
        (method_declaration
            (visibility_modifier) @visibility
            (name) @method
        )
    ]]
)

local function is_same_class(action, class)
    return string.sub(action, 1, string.len(class)) == class
end

local function set_route_to_methods()
    local namespace = vim.api.nvim_create_namespace("laravel.routes")

    artisan.exec("route:list --json", function(j, return_val)
        -- clena namespace
        vim.api.nvim_buf_clear_namespace(0, namespace, 0, -1)
        vim.diagnostic.reset(namespace, 0)

        if return_val ~= 0 then
            utils.notify("set_route_to_methods", { msg = "cant retrive the routes, maybe check Sail", level = "WARN" })
            return
        end

        local route_list = vim.fn.json_decode(j:result())

        local parsers = require("nvim-treesitter.parsers")
        local parser = parsers.get_parser(0)
        local tree = unpack(parser:parse())

        local query = vim.treesitter.get_query("php", "laravel_route_info")

        local class, class_namespace, methods, visibilities = "", "", {}, {}
        local class_pos = 0

        for id, node in query:iter_captures(tree:root(), 0) do
            if query.captures[id] == "class" then
                class = get_node_text(node, 0)
                class_pos = node:start()
            elseif query.captures[id] == "namespace" then
                class_namespace = get_node_text(node, 0)
            elseif query.captures[id] == "method" then
                table.insert(methods, {
                    pos = node:start(),
                    name = get_node_text(node, 0),
                })
            elseif query.captures[id] == "visibility" then
                table.insert(visibilities, get_node_text(node, 0))
            end
        end

        local class_methods = {}

        local full_class = string.format("%s\\%s", class_namespace, class)
        for idx, method in ipairs(methods) do
            if visibilities[idx] == "public" then
                table.insert(class_methods, {
                    full = string.format("%s\\%s@%s", class_namespace, class, method.name),
                    name = method.name,
                    pos = method.pos,
                })
            end
        end

        local errors = {}
        for _, route in pairs(route_list) do
            local found = false
            for _, method in pairs(class_methods) do
                if route.action == method.full then
                    local nice_route = string.format(
                        "[Method: %s, URI: %s, Middleware: %s]",
                        route.method,
                        route.uri,
                        vim.fn.join(route.middleware, ",")
                    )
                    vim.api.nvim_buf_set_extmark(
                        0,
                        namespace,
                        method.pos,
                        0,
                        { virt_text = { { nice_route, "comment" } } }
                    )
                    found = true
                end
            end

            if is_same_class(route.action, full_class) and not found then
                table.insert(errors, {
                    lnum = class_pos,
                    col = 0,
                    message = string.format("missing %s", route.action),
                })
            end
        end

        if #errors > 0 then
            vim.diagnostic.set(namespace, 0, errors)
        end
    end)
end

local group = vim.api.nvim_create_augroup("laravel", {})

route_info.register = function()
    if LaravelConfig.runtime.is_laravel then
        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
            pattern = { "*Controller.php" },
            group = group,
            callback = set_route_to_methods,
        })
    end
end

return route_info
