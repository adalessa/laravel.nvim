local Job = require("plenary.job")
local utils = {}

local get_cmd = function ()
    if Laravel.properties.uses_sail then
        return "vendor/bin/sail"
    end

    return "php"
end

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

---Gets the artisan command
---@param cmd table
---@return table
function utils.get_artisan_cmd(cmd)

	if type(cmd) ~= "table" then
		utils.notify("get_artisan_cmd", {
			msg = "cmd has to be a table",
			level = "ERROR",
		})
		return {}
	end
    local out_cmd = vim.fn.deepcopy(cmd)

    table.insert(out_cmd, 1, get_cmd())
    table.insert(out_cmd, 2, "artisan")

    return out_cmd
end


---Gets the sail command
---@param cmd table
---@return table
function utils.get_sail_cmd(cmd)
	if type(cmd) ~= "table" then
		utils.notify("get_sail_cmd", {
			msg = "cmd has to be a table",
			level = "ERROR",
		})
		return {}
	end

    table.insert(cmd, 1, "vendor/bin/sail")

    return cmd
end


return utils
