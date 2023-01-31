local Dev = require("laravel.dev")

local log = Dev.log

local M = {}

M.app = require("laravel.app")

---Set up laravel plugin
---@param opts laravel.config|nil
function M.setup(opts)
	-- register command for DirChanged
	-- this should be able to check and update the config
	log.trace("setup(): Setting up...")
	require("laravel.autocommands").dir_changed(opts or {})

	M.app.environment = require("laravel.environment").load()

	-- if is not artisan do not continue
	-- but register the dir change to start in case of moving
	-- into a laravel directory
	if not M.app.environment.is_laravel_project then
		log.debug("Not initialize due missing artisan file")
		return
	end

	local defaults = require("laravel.defaults")
	M.app.options = vim.tbl_deep_extend("force", defaults, opts or {})

	log.debug("setup(): Complete config", M.app)

	log.trace("setup(): log_key", Dev.get_log_key())

	M.app.load_commands()
	M.app.load_routes()

	if M.app.options.register_user_commands then
		require("laravel.user-commands").setup()
	end

	if M.app.options.route_info then
		require("laravel.route_info").register()
	end
end

return M
