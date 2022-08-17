local log = require("laravel.dev").log
local utils = require("laravel.utils")
local resource_directory_map = require("laravel.resource_directory_map")

local artisan = {}

local function open_resource(resource, name)
	local directory = resource_directory_map[resource]
	if directory == "" then
		return
	end
	local filename = string.format("%s/%s.php", directory, name)
	if vim.fn.findfile(filename) then
		local uri = vim.uri_from_fname(string.format("%s/%s", vim.fn.getcwd(), filename))
		local buffer = vim.uri_to_bufnr(uri)
		vim.api.nvim_win_set_buf(0, buffer)
	end
end

function artisan.tinker()
    vim.cmd(string.format("%s new term://%s artisan tinker", LaravelConfig.split_cmd, LaravelConfig.runtime.artisan_cmd))
    vim.cmd("startinsert")
end

function artisan.run(cmd)
    local job_cmd = utils.get_artisan_cmd(vim.split(cmd, " "))
	log.debug("artisan.run(): running", job_cmd)
    utils.term_open_output(job_cmd)
end

function artisan.make(resource, name, args)
    args = args or {}
    table.insert(args, 1, "make:"..resource )
    table.insert(args, 2, name)

    if resource == 'command' then
        artisan.clean_cmd_list_cache()
    end

    local job_cmd = utils.get_artisan_cmd(args)
	log.debug("artisan.make(): running", job_cmd)
    local stdout, ret, stderr = utils.get_os_command_output(job_cmd)
    log.trace("artisan.make(): stdout", stdout)
    log.trace("artisan.make(): ret", ret)
    log.trace("artisan.make(): stderr", stderr)
    if ret == 1 then
        log.error("artisan.make(): stdout", stdout)
        log.error("artisan.make(): stderr", stderr)

        return
    end

    open_resource(resource, name)
end

function artisan.list()
    local stdout, ret, stderr = utils.get_os_command_output(utils.get_artisan_cmd({"list", "--raw"}))
    log.trace("artisan.list(): stdout", stdout)
    log.trace("artisan.list(): ret", ret)
    log.trace("artisan.list(): stderr", stderr)

    if ret == 1 then
        log.error("artisan.list(): stdout", stdout)
        log.error("artisan.list(): stderr", stderr)

        return
    end

    local result = {}
    for _, value in ipairs(stdout) do
        local data = vim.split(value, "  ")
        table.insert(result, {
            command = data[1],
            description = data[#data]:match('^%s*(.*)'),
        })
    end

    return result
end

function artisan.help(cmd)
    local stdout, ret, stderr = utils.get_os_command_output(utils.get_artisan_cmd({cmd, "-h"}))
    if ret == 1 then
        log.error("artisan.list(): stdout", stdout)
        log.error("artisan.list(): stderr", stderr)

        return
    end

    return stdout
end

function artisan.clean_cmd_list_cache()
    log.trace("artisan.clean_cmd_list_cache(): cleaning cache")
    LaravelConfig.runtime.cmd_list = {}
end

return artisan
