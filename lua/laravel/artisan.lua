local log = require("laravel.dev").log
local utils = require("laravel.utils")
local runner = require("laravel.runner")

local artisan = {}

local function open_resource(resource, name)
	local directory = Laravel.config.resource_directory_map[resource]
	if directory == "" then
		return
	end
    -- TODO handle migration since that includes a generated name
    -- need to find a way to search just by a part of the name
	local filename = string.format("%s/%s.php", directory, name)
	if vim.fn.findfile(filename) then
		local uri = vim.uri_from_fname(string.format("%s/%s", vim.fn.getcwd(), filename))
		local buffer = vim.uri_to_bufnr(uri)
		vim.api.nvim_win_set_buf(0, buffer)

        return
	end

    utils.notify("open_resource", {
        msg = string.format("Can't find resource %s", filename)
    })
end

---Executes an artisan command
---@param cmd table|string
---@param callback function|nil
---@return table|nil
function artisan.exec(cmd, callback)
    local artisan_cmd = {}
    if type(cmd) == "table" then
        artisan_cmd = cmd
    elseif type(cmd) == "string"  then
        artisan_cmd = vim.split(cmd, " ")
    else
        log.error("artisan.exec(): invalid input", cmd)
        return nil
    end

    local job_cmd = utils.get_artisan_cmd(artisan_cmd)

    if callback == nil then
        return runner.sync(job_cmd)
    end

    return runner.async(job_cmd, callback)
end

---Runs a common on the configure runner
---@param cmd string
---@param cmd_runner string|nil
---@return nil
function artisan.run(cmd, cmd_runner)
    local artisan_cmd = vim.split(cmd, " ")
    local job_cmd = utils.get_artisan_cmd(artisan_cmd)
	log.debug("artisan.run(): running", job_cmd)
    local command = artisan_cmd[1]

    if utils.is_make_command(command) then
        local resource = vim.split(artisan_cmd[1], ":")[2]
        table.remove(artisan_cmd, 1)
        local name = artisan_cmd[1]
        table.remove(artisan_cmd, 1)

        return artisan.make(
            resource,
            name,
            artisan_cmd
        )
    end

    cmd_runner = cmd_runner or Laravel.config.artisan_command_runner[command]
    if cmd_runner ~= nil then
        return runner[cmd_runner](job_cmd)
    end

    -- base on the command can have different runner
    runner.buffer(job_cmd)
end

---Creates a resource
---@param resource string
---@param name string
---@param args table
function artisan.make(resource, name, args)
    args = args or {}
    table.insert(args, 1, "make:"..resource )
    table.insert(args, 2, name)

    if resource == 'command' then
        artisan.clean_cmd_list_cache()
    end

    local stdout, ret, stderr = artisan.exec(args)
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

---returns the help for a command
---@param cmd string
---@return table|nil
function artisan.help(cmd)
    local stdout, ret, stderr = artisan.exec({cmd, "-h"})
    if ret == 1 then
        log.error("artisan.help(): stdout", stdout)
        log.error("artisan.help(): stderr", stderr)

        return
    end

    return stdout
end

---@class Argument
---@field name string

---@class Definition
---@field arguments Argument[]

---@class Command
---@field name string
---@field description string
---@field usage string
---@field help string
---@field definition Definition

---Map from raw command output to command
---@param raw table|nil
---@return Command[]
local function map_commands(raw)
    return vim.fn.json_decode(raw).commands
end

---Gets the commands
---@param clean_cache boolean|nil
---@param silent boolean|nil
---@return Command[]
function artisan.commands(clean_cache, silent)
    clean_cache = clean_cache or false
    silent = silent or false

    if clean_cache or #Laravel.cache.commands == 0 then
        Laravel.cache.commmandas = {}
        local stdout, ret, stderr = artisan.exec({"list", "--format=json"})

        if ret == 1 then
            if not silent then
                log.error("artisan.commands(): stdout", stdout)
                log.error("artisan.commands(): stderr", stderr)
            end
            -- TODO improve error showing
            return {}
        end

        Laravel.cache.commands = map_commands(stdout)
    end

    return Laravel.cache.commands
end

---Gets the route list async
---@param clean_cache boolean|nil
---@param callback function|nil
function artisan.routes(clean_cache, callback)
    clean_cache = clean_cache or false

    if not clean_cache and #Laravel.cache.routes ~= 0 then
        if callback == nil then
            return Laravel.cache.routes
        end

        return callback(Laravel.cache.routes, 0)
    end

    if callback == nil then
        if clean_cache or #Laravel.cache.routes == 0 then
            Laravel.cache.routes = {}
            local stdout, ret, _ = artisan.exec({"route:list", "--json"})

            if ret == 1 then
                -- TODO improve error showing
                return {}
            end

            Laravel.cache.rotues = vim.fn.json_decode(stdout)
        end

        return Laravel.cache.rotues
    end

    artisan.exec({"route:list", "--json"}, function (j, return_val)
        if return_val ~= 0 then
            return callback({}, return_val)
        end

        local route_list = vim.fn.json_decode(j:result())
        Laravel.cache.routes = route_list

        return callback(route_list, 0)
    end)
end

return artisan
