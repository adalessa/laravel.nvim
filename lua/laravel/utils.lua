local Job = require("plenary.job")
local utils = {}

function utils.notify(funname, opts)
	local level = vim.log.levels[opts.level]
	if not level then
		error("Invalid error level", 2)
	end
	vim.notify(string.format("[laravel.%s]: %s", funname, opts.msg), level, {
        title = "laravel.nvim"
    })
end

function utils.is_make_command(cmd)
    local command_split = vim.split(cmd, ":")
    return command_split[1] == "make"
end

function utils.term_open_output(cmd)
    vim.cmd(LaravelConfig.split_cmd .. ' new')
    local new_window = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(new_window, LaravelConfig.split_width + 5)
    local new_buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(new_window, new_buffer)
    local channel_id = vim.api.nvim_open_term(new_buffer, {})

    local function handle_output(_, data)
        vim.fn.chansend(channel_id, data)
    end

	vim.fn.jobstart(cmd, {
        stdeout_buffered = true,
        on_stdout = handle_output,
        on_exit = function ()
            vim.fn.chanclose(channel_id)
            vim.cmd("startinsert")
        end,
        pty = true,
        width = LaravelConfig.split_width,
	})
end

function utils.get_os_command_output(cmd, cwd)
	if type(cmd) ~= "table" then
		utils.notify("get_os_command_output", {
			msg = "cmd has to be a table",
			level = "ERROR",
		})
		return {}
	end
	local command = table.remove(cmd, 1)
	local stderr = {}
	local stdout, ret = Job:new({
		command = command,
		args = cmd,
		cwd = cwd,
		on_stderr = function(_, data)
			table.insert(stderr, data)
		end,
	}):sync()

	return stdout, ret, stderr
end

function utils.run_os_command(cmd, cwd, on_exit)
	if type(cmd) ~= "table" then
		utils.notify("get_os_command_output", {
			msg = "cmd has to be a table",
			level = "ERROR",
		})
		return {}
	end
	local command = table.remove(cmd, 1)
	Job:new({
		command = command,
		args = cmd,
		cwd = cwd,
        on_exit = vim.schedule_wrap(on_exit)
	}):start()
end

function utils.get_artisan_cmd(cmd)
	if type(cmd) ~= "table" then
		utils.notify("get_os_command_output", {
			msg = "cmd has to be a table",
			level = "ERROR",
		})
		return {}
	end

    table.insert(cmd, 1, LaravelConfig.runtime.artisan_cmd)
    table.insert(cmd, 2, "artisan")

    return cmd
end

function utils.get_sail_cmd(cmd)
	if type(cmd) ~= "table" then
		utils.notify("get_os_command_output", {
			msg = "cmd has to be a table",
			level = "ERROR",
		})
		return {}
	end

    table.insert(cmd, 1, LaravelConfig.runtime.artisan_cmd)

    return cmd
end


return utils
