local Dev = require("laravel.dev")
local log = Dev.log

local M = {}

LaravelConfig = LaravelConfig or {}

-- tbl_deep_extend does not work the way you would think
local function merge_table_impl(t1, t2)
	for k, v in pairs(t2) do
		if type(v) == "table" then
			if type(t1[k]) == "table" then
				merge_table_impl(t1[k], v)
			else
				t1[k] = v
			end
		else
			t1[k] = v
		end
	end
end

local function merge_tables(...)
	log.trace("_merge_tables()")
	local out = {}
	for i = 1, select("#", ...) do
		merge_table_impl(out, select(i, ...))
	end
	return out
end

function M.setup(config)
	log.trace("setup(): Setting up...")
	if not config then
		config = {}
	end

	local complete_config = merge_tables({
		split_cmd = "vertical",
		split_width = 120,
        bind_telescope = true,
        ask_for_args = true,
	})

	complete_config.runtime = require("laravel.runtime_config")
    if not complete_config.runtime.has_composer then
        return
    end

	LaravelConfig = merge_tables(complete_config, config)

    LaravelConfig.cmd_list = function ()
        if #LaravelConfig.runtime.cmd_list == 0 then
            LaravelConfig.runtime.cmd_list = require("laravel.artisan").list()
        end

        return LaravelConfig.runtime.cmd_list
    end

	log.debug("setup(): Complete config", LaravelConfig)
	log.trace("setup(): log_key", Dev.get_log_key())

    local function get_artisan_auto_complete()
        local complete_list = {}
        for _, value in ipairs(LaravelConfig.cmd_list()) do
            table.insert(complete_list, value.command)
        end

        return complete_list
    end

	-- Create auto commands
	vim.api.nvim_create_user_command("Artisan", function(args)
		if args.args == "" then
            if LaravelConfig.bind_telescope then
                return require("telescope").extensions.laravel.laravel()
            end
		end

		if args.args == "tinker" then
			return require("laravel.artisan").tinker()
		end

		return require("laravel.artisan").run(args.args)
	end, {
		nargs = "*",
		complete = get_artisan_auto_complete,
	})

	vim.api.nvim_create_user_command("Sail", function(args)
		if args.fargs[1] == "shell" then
			return require("laravel.sail").shell()
		elseif args.fargs[1] == "up" then
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

return M
