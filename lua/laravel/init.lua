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
    local properties = project_properties.get()

    -- if is not artisan do not continue
    -- but register the dir change to start in case of moving
    -- into a laravel directory
    if not properties.has_artisan then
        log.debug("Not initialize due missing artisan file")
        Laravel = {}
        return
    end

	Laravel.config = vim.tbl_deep_extend("force", config, opts or {})
    Laravel.properties = properties
    Laravel.cache = {}

	log.debug("setup(): Complete config", Laravel)

	log.debug("setup(): warm cache", Laravel)
    Laravel.cache = {
        commands = require("laravel.artisan").commands(true, true),
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
