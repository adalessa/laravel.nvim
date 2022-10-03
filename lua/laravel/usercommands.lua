local usercommands = {}

usercommands.sail = function ()
	vim.api.nvim_create_user_command("Sail", function(args)
		if args.fargs[1] == "up" then
			return require("laravel.sail").up()
		elseif args.fargs[1] == "down" then
			return require("laravel.sail").down()
		elseif args.fargs[1] == "restart" then
			return require("laravel.sail").restart()
		else
			return require("laravel.sail").run(args.args)
		end
	end, {
		nargs = "+",
		complete = function()
			return {
				"shell",
				"up",
				"down",
				"restart",
			}
		end,
	})
end


local function get_artisan_auto_complete(current_match, full_command)
    -- avoid getting autocomplete for when parameter is expected
    if (#vim.fn.split(full_command, " ") >= 2 and current_match == "") or #vim.fn.split(full_command, " ") >= 3 then
        return {}
    end
    local complete_list = {}
    for _, value in ipairs(require("laravel.artisan").commands()) do
        table.insert(complete_list, value.command)
    end

    return complete_list
end

usercommands.artisan = function ()
	vim.api.nvim_create_user_command("Artisan", function(args)
		if args.args == "" then
			if Laravel.config.bind_telescope then
				return require("telescope").extensions.laravel.laravel()
			end
		end

		return require("laravel.artisan").run(args.args)
	end, {
		nargs = "*",
		complete = get_artisan_auto_complete,
	})
end

usercommands.composer = function ()
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

usercommands.laravel = function ()
	vim.api.nvim_create_user_command("LaravelCleanArtisanCache", function()
        Laravel.cache = {
            commands = {},
            routes = {},
        }
		print("Artisan cache has been clean")
	end, {})
end

return usercommands
