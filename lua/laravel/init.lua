local Dev = require("laravel.dev")
local config = require("laravel.config")
local project_properties = require("laravel.project_properties")
local autocommands = require("laravel.autocommands")

local log = Dev.log

local M = {}

---@class Laravel
---@field config laravel.config
---@field properties laravel.project_properties
---@field cache laravel.cache
Laravel = Laravel or {}

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

---Set up laravel plugin
---@param opts laravel.config|nil
function M.setup(opts)
    -- register command for DirChanged
    -- this should be able to check and update the config

	log.trace("setup(): Setting up...")
	if not opts then
		opts = {}
	end

    autocommands.dir_changed(opts)

    -- if is not artisan do not continue
    -- but register the dir change to start in case of moving
    -- into a laravel directory
    if vim.fn.filereadable("artisan") == 0 then
        return
    end


	Laravel.config = merge_tables(config, opts)
    Laravel.properties = project_properties
    Laravel.cache = {}

	log.debug("setup(): Complete config", Laravel)

	log.debug("setup(): warm cache", Laravel)
    Laravel.cache = {
        commands = require("laravel.artisan").commands(true),
        routes = {},
    }

	log.trace("setup(): log_key", Dev.get_log_key())

    if Laravel.config.register_user_commands then
        local usercommands = require("laravel.usercommands")
        usercommands.artisan()
        usercommands.sail()
        usercommands.composer()
        usercommands.laravel()
    end

    if Laravel.config.route_info then
        require("laravel.route_info").register()
    end
end

return M
