local M = {}

M.sail = function()
    vim.api.nvim_create_user_command("Sail", function(args)
        local command = args.fargs[1]
        if require("laravel.sail")[command] ~= nil then
            return require("laravel.sail")[command]()
        end

        return require("laravel.sail").run(vim.fn.split(args.args, " "))
    end, {
        nargs = "+",
        complete = function()
            return {
                "shell",
                "up",
                "down",
                "restart",
                "ps",
            }
        end,
    })
end


local function get_artisan_auto_complete(current_match, full_command)
    print(vim.inspect(current_match))
    print(vim.inspect(full_command))
    -- avoid getting autocomplete for when parameter is expected
    if (#vim.fn.split(full_command, " ") >= 2 and current_match == "") or #vim.fn.split(full_command, " ") >= 3 then
        return {}
    end
    local complete_list = {}
    for _, command in ipairs(require("laravel.app").commands()) do
        if current_match == "" or string.match(command.name, current_match) then
            table.insert(complete_list, command.name)
        end
    end

    return complete_list
end

M.artisan = function()
    vim.api.nvim_create_user_command("Artisan", function(args)
        if args.args == "" then
            if require("laravel.app").options.bind_telescope then
                local ok, telescope = pcall(require, "telescope")
                if ok then
                    return telescope.extensions.laravel.commands()
                end
            end
        end
        local resources = require("laravel.resources")
        if resources.is_resource(args.fargs[1]) then
            return resources.create(args.fargs)
        end

        return require("laravel.artisan").run(args.fargs)
    end, {
        nargs = "*",
        complete = get_artisan_auto_complete,
    })
end

M.composer = function()
    vim.api.nvim_create_user_command("Composer", function(args)
        if args.fargs[1] == "update" then
            table.remove(args.fargs, 1)
            return require("laravel.composer").update(vim.fn.join(args.fargs, " "))
        elseif args.fargs[1] == "install" then
            return require("laravel.composer").install()
        elseif args.fargs[1] == "remove" then
            table.remove(args.fargs, 1)
            return require("laravel.composer").remove(vim.fn.join(args.fargs, " "))
        elseif args.fargs[1] == "require" then
            table.remove(args.fargs, 1)
            return require("laravel.composer").require(vim.fn.join(args.fargs, " "))
        end
    end, {
        nargs = "+",
        complete = function()
            return {
                "update",
                "install",
                "remove",
                "require",
            }
        end,
    })
end

M.laravel = function()
    vim.api.nvim_create_user_command("Laravel", function(args)
        if args.fargs == "cache:clean" then
            require("laravel.cache_manager").purge()
            vim.notify("Laravel.nvim cache has been clean", vim.log.levels.INFO, {})
        end
    end, {
        nargs = "+",
        complete = function()
            return {
                "cache:clean"
            }
        end,
    })
end

M.register = function()
    M.artisan()
    M.sail()
    M.composer()
    M.laravel()
end

return M
