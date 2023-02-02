local cache = require("laravel.cache_manager")
local artisan = require("laravel.artisan")
local laravel_command = require("laravel.command")
local log = require("laravel.dev").log

---@param options laravel.config
---@return laravel.app | nil
return function(options)

  local env = require("laravel.environment").load()
  if not env.is_laravel_project then
		log.debug("Not initialize due missing artisan file")
    return nil
  end

	---@class laravel.app
	---@field options laravel.config
	---@field environment laravel.environment
	local app = {
		options = options,
		environment = env,
	}

	app.commands = function()
		return cache.get("commands", function()
			local result = artisan.run({ "list", "--format=json" }, "sync")

			if result.exit_code == 1 then
				log.error("app.commands(): stdout", result.out)
				log.error("app.commands(): stderr", result.err)
				return {}
			end

			return laravel_command.from_json(result.out)
		end)
	end

	app.routes = function()
		return cache.get("routes", function()
			local result = artisan.run({ "route:list", "--json" }, "sync")

			if result.exit_code == 1 then
				log.error("app.routes(): stdout", result.out)
				log.error("app.routes(): stderr", result.err)
				return {}
			end

			return vim.fn.json_decode(result.out)
		end)
	end

	app.load_commands = function()
		cache.forget("commands")
		artisan.run({ "list", "--format=json" }, "async", {
			callback = function(j, exit_code)
				if exit_code == 1 then
					return
				end
				cache.put("commands", laravel_command.from_json(j:result()))
			end,
		})
	end

	app.load_routes = function()
		cache.forget("routes")
		artisan.run({ "route:list", "--json" }, "async", {
			callback = function(j, exit_code)
				if exit_code == 1 then
					return
				end
				cache.put("routes", vim.fn.json_decode(j:result()))
			end,
		})
	end

	return app
end
